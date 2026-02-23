#!/usr/bin/env python3
import sys
import argparse
import os
import re
from rich.console import Console
from rich.panel import Panel
from rich.markdown import Markdown
from rich.table import Table
from rich import box
from rich.text import Text
import questionary

console = Console()

def read_plan(plan_file):
    if not os.path.exists(plan_file):
        return None
    with open(plan_file, 'r') as f:
        return f.read()

def parse_phases(content):
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
            # Remove header markers (## or ###)
            name = re.sub(r'^#+\s*', '', line).strip()
            # Remove status markers from name
            name = re.sub(r'\[.*?\]', '', name).strip()
            name = name.replace('✅', '').strip()
            
            current_phase = {
                "name": name,
                "status": status,
                "raw": line
            }
    
    if current_phase:
        phases.append(current_phase)
    
    return phases

def show_banner(title, style="bold cyan"):
    console.print(Panel(Text(title, justify="center", style=style), box=box.DOUBLE, expand=False))

def show_status(plan_file):
    content = read_plan(plan_file)
    if not content:
        console.print(f"[red]Error: {plan_file} not found[/red]")
        return

    phases = parse_phases(content)
    total = len(phases)
    completed = len([p for p in phases if p['status'] == 'complete'])
    in_progress = len([p for p in phases if p['status'] == 'in_progress'])
    
    table = Table(title="Task Plan Status", box=box.ROUNDED, show_header=True, header_style="bold magenta")
    table.add_column("Phase", style="cyan")
    table.add_column("Status", style="green")
    
    for p in phases:
        status_icon = "⚪"
        style = "white"
        if p['status'] == 'complete':
            status_icon = "✅"
            style = "green"
        elif p['status'] == 'in_progress':
            status_icon = "🔄"
            style = "yellow"
        
        table.add_row(p['name'], f"{status_icon} {p['status'].upper()}", style=style)
            
    console.print(table)
    
    # Progress Bar
    if total > 0:
        pct = int((completed / total) * 100)
        bar_len = 30
        filled = int(bar_len * pct / 100)
        bar = "█" * filled + "░" * (bar_len - filled)
        console.print(f"\n[bold]Overall Progress:[/bold] [{bar}] {pct}%")

def get_menu_style():
    return questionary.Style([
        ('qmark', 'fg:#673ab7 bold'),
        ('question', 'bold'),
        ('answer', 'fg:#f44336 bold'),
        ('pointer', 'fg:#673ab7 bold'),
        ('highlighted', 'fg:#673ab7 bold'),
        ('selected', 'fg:#cc5454'),
        ('separator', 'fg:#cc5454'),
        ('instruction', ''),
        ('text', ''),
        ('disabled', 'fg:#858585 italic')
    ])

def optimize_handoff(output_dir):
    console.clear()
    show_banner("Step 1: Prompt Optimization Complete", "bold green")
    console.print(f"\nPrompt saved to: [underline]{output_dir}/prompt.md[/underline]\n")
    
    choices = [
        questionary.Choice("Proceed to Planning", value="proceed"),
        questionary.Choice("Revise Prompt", value="revise"),
        questionary.Choice("Exit", value="exit")
    ]
    
    answer = questionary.select(
        "Next Step:",
        choices=choices,
        style=get_menu_style()
    ).ask()
    
    print(f"SELECTED: {answer}")

def plan_handoff(plan_file):
    console.clear()
    show_banner("Step 2: Planning Complete", "bold green")
    show_status(plan_file)
    console.print("\n")
    
    choices = [
        questionary.Choice("Execute Plan (Start Phase 1)", value="execute"),
        questionary.Choice("Review Plan", value="review"),
        questionary.Choice("Revise Plan", value="revise"),
        questionary.Choice("Exit", value="exit")
    ]
    
    answer = questionary.select(
        "Next Step:",
        choices=choices,
        style=get_menu_style()
    ).ask()
    
    print(f"SELECTED: {answer}")

def execution_handoff(phase_num, plan_file):
    console.clear()
    show_banner(f"Step 3: Phase {phase_num} Complete", "bold green")
    show_status(plan_file)
    console.print("\n")
    
    content = read_plan(plan_file)
    phases = parse_phases(content)
    
    next_phase_num = int(phase_num) + 1
    next_phase = None
    if next_phase_num <= len(phases):
        next_phase = phases[next_phase_num-1]['name']
    
    choices = []
    if next_phase:
        choices.append(questionary.Choice(f"Proceed to {next_phase}", value="proceed"))
    else:
        choices.append(questionary.Choice("All Phases Complete! (Finish)", value="finish"))
        
    choices.append(questionary.Choice("Review Changes", value="review"))
    choices.append(questionary.Choice("Pause Execution", value="pause"))
    
    answer = questionary.select(
        "Next Step:",
        choices=choices,
        style=get_menu_style()
    ).ask()
    
    print(f"SELECTED: {answer}")

def main():
    parser = argparse.ArgumentParser(description="Modern TUI for Claude Code")
    subparsers = parser.add_subparsers(dest="command")
    
    # Status
    status_parser = subparsers.add_parser("status")
    status_parser.add_argument("--file", default="task_plan.md")
    
    # Optimize Handoff
    opt_parser = subparsers.add_parser("optimize-handoff")
    opt_parser.add_argument("--dir", default=".")
    
    # Plan Handoff
    plan_parser = subparsers.add_parser("plan-handoff")
    plan_parser.add_argument("--file", default="task_plan.md")
    
    # Execution Handoff
    exec_parser = subparsers.add_parser("execution-handoff")
    exec_parser.add_argument("--phase", required=True)
    exec_parser.add_argument("--file", default="task_plan.md")

    args = parser.parse_args()
    
    try:
        if args.command == "status":
            show_status(args.file)
        elif args.command == "optimize-handoff":
            optimize_handoff(args.dir)
        elif args.command == "plan-handoff":
            plan_handoff(args.file)
        elif args.command == "execution-handoff":
            execution_handoff(args.phase, args.file)
        else:
            parser.print_help()
    except KeyboardInterrupt:
        print("\nCancelled by user")
        sys.exit(1)

if __name__ == "__main__":
    main()
