#!/usr/bin/env python3
import os
import sys
import argparse
import subprocess
import json
import tempfile
from pathlib import Path

# Configuration
SKILL_DIR = Path(__file__).parent.parent
REFERENCES_DIR = SKILL_DIR / "references"
LENSES_FILE = REFERENCES_DIR / "reviewer-lenses.md"
PRINCIPLES_FILE = REFERENCES_DIR / "principles.md"

def load_file(path):
    with open(path, 'r') as f:
        return f.read()

def determine_scope(file_paths):
    total_lines = 0
    for file_path in file_paths:
        try:
            with open(file_path, 'r') as f:
                total_lines += len(f.readlines())
        except Exception as e:
            print(f"Warning: Could not read {file_path}: {e}")
    
    if total_lines < 50:
        return "Small", ["Skeptic"]
    elif total_lines < 200:
        return "Medium", ["Skeptic", "Architect"]
    else:
        return "Large", ["Skeptic", "Architect", "Minimalist"]

def get_reviewer_prompt(lens, intent, code_content, principles):
    lens_prompts = {
        "Skeptic": "You are The Skeptic. Find bugs, security issues, and edge cases.",
        "Architect": "You are The Architect. Check system design, coupling, and interfaces.",
        "Minimalist": "You are The Minimalist. Check for simplicity, YAGNI, and readability."
    }
    
    base_prompt = lens_prompts.get(lens, "You are a code reviewer.")
    
    full_prompt = f"""
{base_prompt}

# Intent
The author's intent is: {intent}

# Principles
{principles}

# Code to Review
{code_content}

# Instructions
1. Review the code based ONLY on your assigned Lens ({lens}).
2. Challenge whether the code achieves the intent well.
3. Be specific. Cite line numbers.
4. Output a numbered list of findings.
5. Rate each finding: [HIGH], [MEDIUM], [LOW].
"""
    return full_prompt

def spawn_reviewer(lens, prompt, output_dir):
    output_file = output_dir / f"{lens.lower()}.md"
    print(f"  -> Spawning {lens} reviewer...")
    
    # Try to use 'claude' CLI first
    cmd = ["claude", "-p", prompt]
    
    try:
        # Check if claude is available
        subprocess.check_call(["claude", "--version"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        with open(output_file, 'w') as f:
            process = subprocess.Popen(cmd, stdout=f, stderr=subprocess.PIPE, text=True)
            stdout, stderr = process.communicate()
            
            if process.returncode != 0:
                print(f"Error running {lens} reviewer: {stderr}")
                return False
        return True
    except (FileNotFoundError, subprocess.CalledProcessError):
        print(f"Warning: 'claude' CLI not found or failed. Simulating {lens} reviewer.")
        # Fallback simulation (for environments without CLI access)
        with open(output_file, 'w') as f:
            f.write(f"## {lens} Review (Simulation)\n\n")
            f.write(f"1. [MEDIUM] Simulated finding for {lens}.\n")
            f.write("   - Recommendation: Ensure CLI is configured.\n")
        return True

def main():
    parser = argparse.ArgumentParser(description="Adversarial Review Tool")
    parser.add_argument("files", nargs="+", help="Files to review")
    parser.add_argument("--intent", "-i", required=True, help="Intent of the changes")
    args = parser.parse_args()
    
    # 1. Load Principles
    if not PRINCIPLES_FILE.exists():
        print(f"Error: Principles file not found at {PRINCIPLES_FILE}")
        return
    principles = load_file(PRINCIPLES_FILE)
    
    # 2. Determine Scope
    scope, lenses = determine_scope(args.files)
    print(f"Scope: {scope} ({len(args.files)} files)")
    print(f"Assigned Reviewers: {', '.join(lenses)}")
    
    # Load Code
    code_content = ""
    for file_path in args.files:
        code_content += f"\n--- File: {file_path} ---\n"
        try:
            code_content += load_file(file_path)
        except Exception as e:
            code_content += f"[Error reading file: {e}]\n"

    # 3. Spawn Reviewers
    review_dir = Path(tempfile.mkdtemp(prefix="adversarial-review-"))
    print(f"Review artifacts directory: {review_dir}")
    
    results = []
    for lens in lenses:
        prompt = get_reviewer_prompt(lens, args.intent, code_content, principles)
        success = spawn_reviewer(lens, prompt, review_dir)
        if success:
            output_file = review_dir / f"{lens.lower()}.md"
            if output_file.exists():
                results.append((lens, load_file(output_file)))
    
    # 4. Synthesize Verdict
    print("\n" + "="*40)
    print("       ADVERSARIAL REVIEW VERDICT")
    print("="*40 + "\n")
    
    print(f"## Intent\n{args.intent}\n")
    
    for lens, finding in results:
        print(f"### {lens} Findings")
        print(finding)
        print("-" * 20)
    
    print("\n## Lead Judgment Required")
    print("Review the findings above. Accept or Reject each finding based on the project principles.")

if __name__ == "__main__":
    main()
