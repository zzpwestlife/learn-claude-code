#!/usr/bin/env python3
import sys
import re
import os

def parse_makefile(content):
    """
    Parse Makefile content into a list of (target_names, block_content) tuples.
    target_names is a list of strings.
    block_content is the full string of that block (including comments before it).
    """
    blocks = []
    lines = content.splitlines()
    current_block = []
    current_targets = []
    
    # Regex to identify target lines: "target1 target2: deps"
    # We ignore .PHONY for now and handle it separately or treat it as a target
    target_pattern = re.compile(r'^([a-zA-Z0-9_\-\.\s]+):')

    for line in lines:
        # Check if line starts a new target definition
        # But exclude lines starting with tab (commands) or # (comments) unless it's a target line
        if not line.startswith('\t') and ':' in line and '=' not in line:
             match = target_pattern.match(line)
             if match:
                 # If we have a previous block accumulating, save it
                 if current_targets:
                     blocks.append((current_targets, '\n'.join(current_block)))
                     current_block = []
                     current_targets = []
                 
                 # Parse new targets
                 targets_part = match.group(1)
                 # Split by space, but handle escaped spaces if necessary (rare in makefiles targets)
                 new_targets = [t.strip() for t in targets_part.split()]
                 current_targets = new_targets
        
        current_block.append(line)

    # Append last block
    if current_targets:
        blocks.append((current_targets, '\n'.join(current_block)))
        
    return blocks

def get_existing_targets(content):
    """
    Quickly extract all defined targets from a Makefile to check existence.
    """
    targets = set()
    lines = content.splitlines()
    for line in lines:
        if not line.startswith('\t') and ':' in line and '=' not in line:
            parts = line.split(':')[0]
            for t in parts.split():
                targets.add(t.strip())
    return targets

def merge_makefiles(source_path, target_path):
    with open(source_path, 'r') as f:
        source_content = f.read()
    
    if not os.path.exists(target_path):
        # Target doesn't exist, just copy
        print(f"Target {target_path} does not exist. Copying full file.")
        with open(target_path, 'w') as f:
            f.write(source_content)
        return True

    with open(target_path, 'r') as f:
        target_content = f.read()

    existing_targets = get_existing_targets(target_content)
    source_blocks = parse_makefile(source_content)
    
    added_blocks = []
    skipped_targets = []
    
    for targets, block in source_blocks:
        # Check if ANY of the targets in this block already exist
        conflict = False
        for t in targets:
            if t in existing_targets:
                conflict = True
                skipped_targets.append(t)
                break
        
        if not conflict:
            added_blocks.append(block)
        else:
            # If conflict, we could try to rename or just skip
            # For now, let's skip but maybe we can add a commented out version?
            # Or better: check if it's a "standard" target like 'all' or 'test'.
            # If it's a specific tool target (unittest), we really want it.
            pass

    if not added_blocks:
        print("No new targets to merge (all targets already exist).")
        return False

    # Append to target file
    with open(target_path, 'a') as f:
        f.write("\n\n# ==========================================\n")
        f.write("# Merged by Learn Claude Code Installer\n")
        f.write("# ==========================================\n\n")
        for block in added_blocks:
            f.write(block + "\n\n")
    
    print(f"Successfully merged {len(added_blocks)} blocks.")
    if skipped_targets:
        print(f"Skipped existing targets: {', '.join(skipped_targets)}")
    
    return True

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: merge_makefile.py <source_file> <target_file>")
        sys.exit(1)
    
    merge_makefiles(sys.argv[1], sys.argv[2])
