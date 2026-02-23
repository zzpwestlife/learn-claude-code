#!/usr/bin/env python3
import sys
import os
import re
import hashlib
from typing import Optional, Dict, List
from pathlib import Path

# Constants
STATE_DIR = Path(".claude/tmp")
AUDIT_LOG = Path(".claude/audit/planning.log")
STATUS_FILE = Path(".claude/tmp/planning_status.md")

# --- Plan Parser Logic (Merged from claude_utils.plan_parser) ---

def read_file(file_path: str) -> Optional[str]:
    if not os.path.exists(file_path):
        return None
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

def parse_plan(file_path: str) -> Dict:
    content = read_file(file_path)
    if not content:
        return {"error": "File not found"}

    phases = []
    lines = content.split('\n')
    current_phase = None
    
    for line in lines:
        if line.strip().startswith('### Phase') or line.strip().startswith('## Phase'):
            if current_phase:
                phases.append(current_phase)
            
            # Extract status
            status = "pending"
            if "[x]" in line or "[complete]" in line.lower() or "✅" in line:
                status = "complete"
            elif "[in_progress]" in line.lower():
                status = "in_progress"
            
            # Extract name
            name = re.sub(r'^#+\s*', '', line).strip()
            name = re.sub(r'\[.*?\]', '', name).strip()
            name = name.replace('✅', '').strip()
            
            current_phase = {
                "name": name,
                "status": status,
                "raw": line
            }
    
    if current_phase:
        phases.append(current_phase)
        
    total = len(phases)
    completed = len([p for p in phases if p['status'] == 'complete'])
    in_progress = len([p for p in phases if p['status'] == 'in_progress'])
    
    return {
        "phases": phases,
        "total": total,
        "completed": completed,
        "in_progress": in_progress,
        "is_all_complete": total > 0 and completed == total
    }

# --- Status Checker Logic (Merged from claude_utils.status_checker) ---

def get_state_file(plan_file: str) -> Path:
    plan_path = Path(plan_file).resolve()
    plan_hash = hashlib.md5(str(plan_path).encode()).hexdigest()
    return STATE_DIR / f"phase_state_{plan_hash}"

def check_plan_status(plan_file: str) -> Optional[str]:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    AUDIT_LOG.parent.mkdir(parents=True, exist_ok=True)
    STATUS_FILE.parent.mkdir(parents=True, exist_ok=True)

    if not os.path.exists(plan_file):
        return None

    status = parse_plan(plan_file)
    if "error" in status:
        return None

    total = status["total"]
    completed = status["completed"]
    in_progress = status["in_progress"]
    
    # Generate Status File
    with open(STATUS_FILE, "w", encoding="utf-8") as f:
        f.write("# Planning Status\n")
        f.write(f"- Total Phases: {total}\n")
        f.write(f"- Completed: {completed}\n")
        f.write(f"- In Progress: {in_progress}\n\n")
        f.write("## Details\n")
        for p in status["phases"]:
            f.write(f"- {p['name']} ({p['status']})\n")

    # Check State Transition
    state_file = get_state_file(plan_file)
    prev_complete = 0
    if state_file.exists():
        try:
            prev_complete = int(state_file.read_text().strip())
        except ValueError:
            prev_complete = 0

    # Update State
    state_file.write_text(str(completed))

    # Event Logic
    event = None
    if status["is_all_complete"]:
        event = "ALL PHASES COMPLETE"
    elif completed > prev_complete:
        event = "EVENT: PHASE_COMPLETE"
    elif total > 0 and completed == 0 and in_progress == 0:
        event = "EVENT: PLAN_READY"

    return event

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 check_complete.py <plan_file>")
        sys.exit(1)

    plan_file = sys.argv[1]
    event = check_plan_status(plan_file)
    
    if event:
        print(event)

if __name__ == "__main__":
    main()
