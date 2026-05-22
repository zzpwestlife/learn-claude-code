#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const PENDING_FILE = path.join(process.env.HOME, '.claude', 'skill-traces', 'pending.jsonl');
const SKILLS_DIR = path.join(process.env.HOME, '.claude', 'skills');

const argv = process.argv.slice(2);
const skillFilter = argv.includes('--skill') ? argv[argv.indexOf('--skill') + 1] : null;
const autoMode = argv.includes('--auto');
const splitArg = argv.includes('--split') ? argv[argv.indexOf('--split') + 1] : 'dev';

function loadPending() {
  if (!fs.existsSync(PENDING_FILE)) return [];
  return fs.readFileSync(PENDING_FILE, 'utf8')
    .trim().split('\n').filter(Boolean)
    .map(l => { try { return JSON.parse(l); } catch { return null; } })
    .filter(Boolean);
}

function savePending(traces) {
  fs.writeFileSync(PENDING_FILE, traces.map(t => JSON.stringify(t)).join('\n') + '\n', 'utf8');
}

function promoteTrace(trace, split) {
  const datasetDir = path.join(SKILLS_DIR, trace.skill, 'dataset');
  if (!fs.existsSync(datasetDir)) {
    console.log(`  ⚠  No dataset dir for "${trace.skill}": ${datasetDir}`);
    return false;
  }
  const tracesDir = path.join(datasetDir, 'traces');
  fs.mkdirSync(tracesDir, { recursive: true });

  fs.writeFileSync(path.join(tracesDir, `${trace.id}.json`), JSON.stringify(trace, null, 2), 'utf8');

  const entry = {
    id: trace.id,
    input: trace.input,
    expected: trace.expected_output,
    skill: trace.skill,
    split,
    trace_path: `traces/${trace.id}.json`,
    notes: trace.status === 'partial' ? 'partial – expected_output may be incomplete' : '',
  };
  fs.appendFileSync(path.join(datasetDir, `${split}.jsonl`), JSON.stringify(entry) + '\n', 'utf8');
  return true;
}

function age(timestamp) {
  const ms = Date.now() - new Date(timestamp).getTime();
  const m = Math.floor(ms / 60000);
  if (m < 60) return `${m}m ago`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h ago`;
  return `${Math.floor(h / 24)}d ago`;
}

async function run() {
  let traces = loadPending();
  const toReview = traces.filter(t =>
    (t.status === 'pending' || t.status === 'partial') &&
    (!skillFilter || t.skill === skillFilter)
  );

  if (toReview.length === 0) {
    console.log('No pending traces to review.');
    return;
  }

  console.log(`\nPending traces: ${toReview.length}${skillFilter ? ` (skill: ${skillFilter})` : ''}`);

  if (autoMode) {
    let promoted = 0;
    for (const trace of toReview) {
      if (promoteTrace(trace, splitArg)) {
        traces.find(t => t.id === trace.id).status = 'promoted';
        promoted++;
        console.log(`  ✓  ${trace.skill}  ${trace.id}  → ${splitArg}`);
      }
    }
    savePending(traces);
    console.log(`\nDone: ${promoted} trace(s) promoted to ${splitArg}.`);
    return;
  }

  // Interactive mode
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  const ask = q => new Promise(resolve => rl.question(q, resolve));

  for (const trace of toReview) {
    console.log('\n' + '─'.repeat(64));
    console.log(`Skill:  ${trace.skill}  [${trace.status}]  ${age(trace.timestamp)}`);
    console.log(`Input:  ${(trace.input || '(empty)').slice(0, 120)}`);
    console.log(`Output: ${(trace.expected_output || '(empty)').slice(0, 280)}`);
    console.log('');

    const ans = (await ask('[y]dev  [g]gt  [n]skip  [d]delete  [q]quit › ')).trim().toLowerCase();

    if (ans === 'q') break;
    if (ans === 'n') continue;
    if (ans === 'd') {
      traces.find(t => t.id === trace.id).status = 'deleted';
      console.log('  Deleted.');
      continue;
    }

    const split = ans === 'g' ? 'gt' : 'dev';
    if (promoteTrace(trace, split)) {
      traces.find(t => t.id === trace.id).status = 'promoted';
      console.log(`  ✓ promoted → ${split}`);
    }
  }

  rl.close();
  savePending(traces);
  console.log('\nDone.');
}

run().catch(err => { console.error(err.message); process.exit(1); });
