#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const mode = process.argv[2]; // 'post-tool' | 'stop'
const PENDING_DIR = path.join(process.env.HOME, '.claude', 'skill-traces');
const PENDING_FILE = path.join(PENDING_DIR, 'pending.jsonl');

async function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.on('data', chunk => { data += chunk; });
    process.stdin.on('end', () => {
      try { resolve(JSON.parse(data)); } catch { resolve({}); }
    });
    process.stdin.on('error', () => resolve({}));
  });
}

function findTranscript(sessionId) {
  const projectsDir = path.join(process.env.HOME, '.claude', 'projects');
  if (!fs.existsSync(projectsDir)) return null;
  try {
    for (const proj of fs.readdirSync(projectsDir)) {
      const candidate = path.join(projectsDir, proj, `${sessionId}.jsonl`);
      if (fs.existsSync(candidate)) return candidate;
    }
  } catch {}
  return null;
}

function extractText(content) {
  if (typeof content === 'string') return content.trim();
  if (!Array.isArray(content)) return '';
  return content.filter(c => c?.type === 'text').map(c => c?.text || '').join('').trim();
}

function parseTranscript(transcriptPath) {
  const content = fs.readFileSync(transcriptPath, 'utf8');
  let userInput = '';
  let assistantOutput = '';
  for (const line of content.trim().split('\n')) {
    if (!line.trim()) continue;
    try {
      const entry = JSON.parse(line);
      const role = entry?.message?.role || entry?.role || entry?.type;
      const rawContent = entry?.message?.content || entry?.content;
      if (role === 'user') {
        const text = extractText(rawContent);
        if (text) userInput = text;
      } else if (role === 'assistant') {
        const text = extractText(rawContent);
        if (text) assistantOutput = text;
      }
    } catch {}
  }
  return { userInput, assistantOutput };
}

function ensurePendingDir() {
  fs.mkdirSync(PENDING_DIR, { recursive: true });
}

function appendPending(traces) {
  ensurePendingDir();
  for (const trace of traces) {
    fs.appendFileSync(PENDING_FILE, JSON.stringify(trace) + '\n', 'utf8');
  }
}

function makeId() {
  const d = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  return `auto-${d}-${Date.now()}`;
}

async function runPostTool() {
  const payload = await readStdin();
  const skill = payload?.tool_input?.skill;
  const args = payload?.tool_input?.args || '';
  const sessionId = payload?.session_id;
  if (!skill || !sessionId) return;

  const stubPath = `/tmp/skill-stub-${sessionId}.json`;
  let stubs = [];
  if (fs.existsSync(stubPath)) {
    try { stubs = JSON.parse(fs.readFileSync(stubPath, 'utf8')); } catch {}
  }
  stubs.push({ skill, args, timestamp: new Date().toISOString() });
  fs.writeFileSync(stubPath, JSON.stringify(stubs), 'utf8');
}

async function runStop() {
  const payload = await readStdin();
  const sessionId = payload?.session_id;
  if (!sessionId) return;

  const stubPath = `/tmp/skill-stub-${sessionId}.json`;
  if (!fs.existsSync(stubPath)) return;

  let stubs;
  try { stubs = JSON.parse(fs.readFileSync(stubPath, 'utf8')); }
  catch { try { fs.unlinkSync(stubPath); } catch {} return; }

  const transcriptPath = payload?.transcript_path || findTranscript(sessionId);

  let userInput = '';
  let assistantOutput = '';
  let status = 'partial';

  if (transcriptPath && fs.existsSync(transcriptPath)) {
    try {
      ({ userInput, assistantOutput } = parseTranscript(transcriptPath));
      if (userInput || assistantOutput) status = 'pending';
    } catch (err) {
      process.stderr.write(`trace-recorder stop parse error: ${err.message}\n`);
    }
  }

  const traces = stubs.map(stub => ({
    id: makeId(),
    skill: stub.skill,
    input: userInput,
    expected_output: assistantOutput.slice(0, 3000),
    args: stub.args,
    timestamp: stub.timestamp,
    session_id: sessionId,
    transcript_path: transcriptPath || '',
    status,
  }));

  try { appendPending(traces); }
  catch (err) { process.stderr.write(`trace-recorder stop write error: ${err.message}\n`); }

  try { fs.unlinkSync(stubPath); } catch {}
}

(async () => {
  try {
    if (mode === 'post-tool') await runPostTool();
    else if (mode === 'stop') await runStop();
  } catch (err) {
    process.stderr.write(`trace-recorder unexpected error: ${err.message}\n`);
  }
  process.exit(0);
})();
