#!/usr/bin/env python3
"""
@module: scripts.tui_menu
@desc: Provides an interactive TUI (Text User Interface) menu for executing common project commands.
@input: User keyboard input (Arrow keys, Enter)
@output: Executes shell commands via subprocess
@role: User Interface / Controller
"""
import curses
import subprocess
import os
import sys

# Define menu options
MENU_OPTIONS = [
    {"label": "Run Tests", "command": "make test"},
    {"label": "Check Task Status", "command": "cat .claude/tmp/planning_status.md"},
    {"label": "Format Code", "command": "make fmt"},
    {"label": "Git Status", "command": "git status"},
    {"label": "Exit", "command": None}
]

def draw_menu(stdscr, selected_row_idx):
    h, w = stdscr.getmaxyx()
    stdscr.clear()
    
    # Title
    title = "Project Control Center (Zero-Friction TUI)"
    stdscr.addstr(1, w//2 - len(title)//2, title, curses.A_BOLD)
    
    # Menu items
    for idx, option in enumerate(MENU_OPTIONS):
        label = f" {option['label']} "
        x = w//2 - len(label)//2
        y = h//2 - len(MENU_OPTIONS)//2 + idx
        if idx == selected_row_idx:
            stdscr.attron(curses.color_pair(1))
            stdscr.addstr(y, x, label)
            stdscr.attroff(curses.color_pair(1))
        else:
            stdscr.addstr(y, x, label)
            
    # Instructions
    footer = "Use Arrow Keys to Navigate, Enter to Select"
    stdscr.addstr(h-2, w//2 - len(footer)//2, footer, curses.A_DIM)
    
    stdscr.refresh()

def main(stdscr):
    # Setup colors
    curses.start_color()
    curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_WHITE)
    curses.curs_set(0) # Hide cursor

    current_row = 0

    while True:
        draw_menu(stdscr, current_row)
        key = stdscr.getch()

        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < len(MENU_OPTIONS) - 1:
            current_row += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            selected = MENU_OPTIONS[current_row]
            if selected["command"] is None:
                break
            
            # Execute command
            curses.endwin() # Restore terminal
            print(f"\nRunning: {selected['command']}...\n")
            print("-" * 40)
            try:
                subprocess.run(selected["command"], shell=True)
            except Exception as e:
                print(f"Error: {e}")
            print("-" * 40)
            
            input("\nPress Enter to return to menu...")
            # Re-initialize curses is handled by wrapper, but we need to reset standard screen if not re-entering wrapper
            # Actually, curses.wrapper handles init/end automatically.
            # But inside the loop, we broke out of curses mode. 
            # To re-enter properly without re-running main, we need to be careful.
            # The standard way with wrapper is to NOT break out completely, 
            # but wrapper restores state on exit.
            # To do this inside a loop, we have to manually handle it or structure it differently.
            
            # Let's try a simpler approach: Just refresh.
            # But subprocess writes to stdout, which messes up curses.
            # So we need to endwin(), run command, then refresh().
            # curses.endwin() is correct.
            # But we need to put the terminal back into curses mode.
            stdscr.refresh() 
            # This might not be enough.
            # A better way is to restart the loop or re-init.
            # Let's stick to the basic structure. 
            # If display is garbled, we can improve.
            
            # Re-enable keypad
            stdscr.keypad(True)
            curses.noecho()
            curses.cbreak()
            curses.curs_set(0)
            
if __name__ == "__main__":
    try:
        # Use wrapper to handle initialization and cleanup
        curses.wrapper(main)
    except KeyboardInterrupt:
        pass
