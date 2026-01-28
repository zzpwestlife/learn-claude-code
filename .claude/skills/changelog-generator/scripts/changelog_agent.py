#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Claude Code Agent - Changelog Generator
用于分析当前分支与主分支的差异，并自动生成 CHANGELOG.md
"""

import os
import sys
import subprocess
import re
import datetime
import argparse
from collections import defaultdict
import json
import fnmatch

class ChangelogAgent:
    def __init__(self, options):
        self.options = options
        self.repo_dir = os.getcwd()
        self.changelog_file = os.path.join(self.repo_dir, "CHANGELOG.md")
        self.config = self._load_config()
        self.main_branch = self._detect_main_branch()

    def _load_config(self):
        """加载配置文件"""
        config_paths = [
            os.path.join(self.repo_dir, "changelog_config.json"),
            os.path.join(self.repo_dir, ".claude", "changelog_config.json")
        ]
        
        default_config = {
            "ignore_patterns": [],
            "commit_url_template": "" # e.g. https://github.com/user/repo/commit/{hash}
        }
        
        for path in config_paths:
            if os.path.exists(path):
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        user_config = json.load(f)
                        default_config.update(user_config)
                        if self.options.verbose:
                            print(f"已加载配置文件: {path}")
                        return default_config
                except Exception as e:
                    print(f"配置文件加载失败 {path}: {e}")
        
        return default_config

    def _run_git(self, args):
        """运行 git 命令并返回输出"""
        try:
            result = subprocess.check_output(
                ["git"] + args, 
                stderr=subprocess.STDOUT,
                cwd=self.repo_dir
            )
            return result.decode('utf-8').strip()
        except subprocess.CalledProcessError as e:
            if self.options.verbose:
                print(f"Git Error: {e.output.decode('utf-8')}")
            return None

    def _detect_main_branch(self):
        """自动检测主分支名称 (main 或 master)"""
        branches = self._run_git(["branch", "-r"])
        if not branches:
            return "main" # 默认回退
        
        if "origin/main" in branches:
            return "main"
        elif "origin/master" in branches:
            return "master"
        
        # 尝试本地分支
        local_branches = self._run_git(["branch"])
        if "main" in local_branches:
            return "main"
        elif "master" in local_branches:
            return "master"
            
        return "main" # 最终默认

    def get_current_branch(self):
        return self._run_git(["rev-parse", "--abbrev-ref", "HEAD"])

    def get_diff_commits(self):
        """获取当前分支与主分支的差异提交"""
        current = self.get_current_branch()
        if current == self.main_branch:
            print(f"当前已在 {self.main_branch} 分支，无法对比差异。请在功能分支运行。")
            return []

        # 获取 merge base
        merge_base = self._run_git(["merge-base", self.main_branch, current])
        if not merge_base:
            print("无法找到 merge base，可能分支历史不相关。")
            return []

        # 获取差异提交
        # 使用 --name-only 获取变更文件列表
        # 分隔符使用非常见字符，避免文件名冲突
        separator = "|||||" 
        # log_format: hash | author | date | subject | body
        log_format = f"%h{separator}%an{separator}%ad{separator}%s{separator}%b"
        
        # 注意: --name-only 会在 log message 后列出文件名
        logs = self._run_git(["log", f"{merge_base}..{current}", f"--format={log_format}", "--date=short", "--name-only"])
        
        if not logs:
            return []

        commits = []
        current_commit = None
        
        lines = logs.split('\n')
        for line in lines:
            line = line.strip()
            if not line:
                continue
                
            if separator in line and len(line.split(separator)) >= 5:
                # 新的 commit 行
                parts = line.split(separator)
                if len(parts) >= 5:
                    # 如果之前有 commit 正在处理，先保存
                    if current_commit:
                        if self._should_include_commit(current_commit):
                            commits.append(current_commit)
                    
                    current_commit = {
                        "hash": parts[0],
                        "author": parts[1],
                        "date": parts[2],
                        "message": parts[3],
                        "body": parts[4], # Capture body
                        "files": []
                    }
            else:
                # 文件行 (或者 body 的多行部分，如果 body 包含 separator 会有问题，但几率极小)
                # git log --format puts body on one line if %b is used? No, %b preserves newlines.
                # However, with --name-only, file list comes AFTER the message.
                # We need to be careful. The log format puts everything before files.
                # But %b might be multiline.
                # Let's verify behavior. git log --format="%s%n%b" prints subject newline body.
                # Our format uses separators.
                
                # If %b has newlines, they will appear as lines without separator.
                # But --name-only output is distinct.
                # Files usually don't have spaces (or at least not typically confusing).
                # But a body line might look like a file.
                # A robust parser is needed.
                # For simplicity in this script, we assume %b is flattened or we handle it.
                # Actually, strictly speaking, `git log` output with custom format and --name-only:
                # <format output>
                # <newline>
                # <file1>
                # <file2>
                
                # If %b contains newlines, we will see:
                # hash|author|date|subject|line1
                # line2
                # line3
                # 
                # file1
                # file2
                
                # The "separator in line" check handles the start of a commit.
                # Everything else is either body or files.
                # Since we can't easily distinguish body lines from file lines if both are arbitrary strings,
                # we might rely on the fact that files are usually at the end.
                # But wait, if we use a specific delimiter for the END of the commit message, that would help.
                # Let's add a specialized END marker.
                pass
        
        # Re-implementing get_diff_commits with a safer delimiter approach
        return self._get_diff_commits_robust(merge_base, current)

    def _get_diff_commits_robust(self, merge_base, current):
        """更健壮的提交解析实现"""
        commit_sep = "||COMMIT_START||"
        field_sep = "||FIELD_SEP||"
        
        # format: COMMIT_START|hash|author|date|subject|body
        log_format = f"{commit_sep}%h{field_sep}%an{field_sep}%ad{field_sep}%s{field_sep}%b"
        
        logs = self._run_git(["log", f"{merge_base}..{current}", f"--format={log_format}", "--date=short", "--name-only"])
        
        if not logs:
            return []

        commits = []
        current_commit = None
        
        lines = logs.split('\n')
        for line in lines:
            line = line.strip()
            if not line:
                continue
                
            if line.startswith(commit_sep):
                # Save previous
                if current_commit:
                    if self._should_include_commit(current_commit):
                        commits.append(current_commit)
                
                # Parse new
                content = line[len(commit_sep):]
                parts = content.split(field_sep)
                # parts: hash, author, date, subject, body (rest)
                if len(parts) >= 4:
                    msg_hash = parts[0]
                    author = parts[1]
                    date = parts[2]
                    subject = parts[3]
                    body = field_sep.join(parts[4:]) if len(parts) > 4 else ""
                    
                    current_commit = {
                        "hash": msg_hash,
                        "author": author,
                        "date": date,
                        "message": subject,
                        "body": body,
                        "files": []
                    }
            else:
                # It's either a continuation of body or a file
                # With --name-only, files are listed after the commit message block.
                # But git log doesn't strictly separate message end and file list.
                # However, files usually don't look like English text sentences.
                # A better way is to NOT use --name-only in the same command if possible,
                # or use --name-status which adds A/M/D prefix.
                # For now, we will treat lines not starting with separator as files if we have a commit.
                # BUT this is risky for multiline bodies.
                # Strategy: Use two commands. One for info, one for files. Or `git log --name-only` produces predictable output?
                # Actually, `git log --format=...` output ends, then a newline, then files.
                # If we put a special marker at the END of the format, we can split.
                pass

        # Let's use a simpler approach: Get commits first (info), then files for each if needed.
        # But getting files for each commit individually is slow (N+1).
        # We can accept the risk or improve the delimiter.
        
        # Revised approach:
        # Use a very distinct end marker in format.
        end_marker = "||COMMIT_END||"
        log_format = f"{commit_sep}%h{field_sep}%an{field_sep}%ad{field_sep}%s{field_sep}%b{end_marker}"
        
        logs = self._run_git(["log", f"{merge_base}..{current}", f"--format={log_format}", "--date=short", "--name-only"])
        
        commits = []
        current_commit = None
        in_message = False
        
        lines = logs.split('\n')
        for line in lines:
            line = line.strip()
            if not line:
                continue
            
            if line.startswith(commit_sep):
                if current_commit:
                    if self._should_include_commit(current_commit):
                        commits.append(current_commit)
                
                content = line[len(commit_sep):]
                # Check if it contains end marker
                if end_marker in content:
                    # Single line case
                    main_part, rest = content.split(end_marker, 1)
                    parts = main_part.split(field_sep)
                    if len(parts) >= 4:
                        current_commit = {
                            "hash": parts[0],
                            "author": parts[1],
                            "date": parts[2],
                            "message": parts[3],
                            "body": field_sep.join(parts[4:]) if len(parts) > 4 else "",
                            "files": []
                        }
                    in_message = False
                else:
                    # Multi line case start
                    parts = content.split(field_sep)
                    if len(parts) >= 4:
                        current_commit = {
                            "hash": parts[0],
                            "author": parts[1],
                            "date": parts[2],
                            "message": parts[3],
                            "body": field_sep.join(parts[4:]) if len(parts) > 4 else "",
                            "files": []
                        }
                    in_message = True
            elif in_message:
                if end_marker in line:
                    # End of message found
                    part, _ = line.split(end_marker, 1)
                    current_commit["body"] += "\n" + part
                    in_message = False
                else:
                    current_commit["body"] += "\n" + line
            else:
                # Files
                if current_commit:
                    current_commit["files"].append(line)
        
        if current_commit and self._should_include_commit(current_commit):
            commits.append(current_commit)
            
        return commits

    def _should_include_commit(self, commit):
        """检查提交是否应该被包含（基于忽略规则）"""
        if not self.config["ignore_patterns"]:
            return True
            
        changed_files = commit["files"]
        if not changed_files:
            return True 
            
        all_ignored = True
        for f in changed_files:
            is_ignored = False
            for pattern in self.config["ignore_patterns"]:
                if fnmatch.fnmatch(f, pattern):
                    is_ignored = True
                    break
            if not is_ignored:
                all_ignored = False
                break
        
        return not all_ignored

    def parse_commits(self, commits):
        """解析提交信息，分类变更"""
        cc_regex = re.compile(r"^(\w+)(?:\(([^)]+)\))?: (.+)$")
        
        changes = defaultdict(list)
        
        type_mapping = {
            "feat": "✨ 新功能 (Features)",
            "fix": "🐛 问题修复 (Bug Fixes)",
            "docs": "📚 文档更新 (Documentation)",
            "style": "💎 代码格式 (Styles)",
            "refactor": "♻️ 代码重构 (Code Refactoring)",
            "perf": "🚀 性能优化 (Performance)",
            "test": "✅ 测试 (Tests)",
            "build": "👷 构建系统 (Build)",
            "ci": "🔧 CI配置 (CI)",
            "chore": "🎫 杂项 (Chores)",
            "revert": "⏪ 回滚 (Reverts)"
        }

        for commit in commits:
            msg = commit["message"]
            body = commit["body"]
            match = cc_regex.match(msg)
            
            c_type = "other"
            c_scope = None
            c_desc = msg
            
            if match:
                c_type = match.group(1)
                c_scope = match.group(2) if match.group(2) else ""
                c_desc = match.group(3)
            
            # 增强分析 Body
            enhanced_info = self._analyze_body(body, c_type)
            
            # 确定分类
            category = type_mapping.get(c_type, "🔨 其他变更 (Other Changes)")
            
            # 特殊分类调整
            if c_type == 'refactor' and (c_scope == 'arch' or 'migration' in body.lower() or 'architecture' in body.lower()):
                category = "🏗️ 架构调整 (Architecture)"
            elif enhanced_info.get('is_dep_update'):
                category = "📦 依赖更新 (Dependencies)"
            
            commit_info = {
                "scope": c_scope,
                "description": c_desc,
                "hash": commit["hash"],
                "author": commit["author"],
                "body": body,
                "enhanced_info": enhanced_info
            }
            changes[category].append(commit_info)
                
        return changes

    def _analyze_body(self, body, c_type):
        """分析提交 Body，提取关键信息"""
        info = {}
        if not body:
            return info
            
        # 提取 Breaking Change
        if "BREAKING CHANGE" in body:
            parts = body.split("BREAKING CHANGE")
            if len(parts) > 1:
                bc_text = parts[1].strip()
                if bc_text.startswith(":"):
                    bc_text = bc_text[1:].strip()
                info["breaking_change"] = bc_text

        lower_body = body.lower()
        
        # 提取示例 (Example)
        if "example" in lower_body or "usage" in lower_body:
            info["has_example"] = True
            
        # 提取性能指标 (Perf)
        if c_type == "perf" and any(k in lower_body for k in ["faster", "slower", "ms", "%", "memory", "cpu"]):
            info["has_metrics"] = True
            
        # 提取修复详情 (Fix)
        if c_type == "fix" and ("impact" in lower_body or "solution" in lower_body):
            info["has_fix_details"] = True
            
        # 提取依赖更新 (Deps)
        if "bumps" in lower_body and "from" in lower_body and "to" in lower_body:
             info["is_dep_update"] = True
             
        return info

    def generate_markdown(self, changes, version):
        """生成 Markdown 格式的变更日志"""
        date_str = datetime.date.today().strftime("%Y-%m-%d")
        md = f"\n## [{version}] - {date_str}\n\n"
        
        priority_order = [
            "🏗️ 架构调整 (Architecture)",
            "✨ 新功能 (Features)",
            "🐛 问题修复 (Bug Fixes)",
            "🚀 性能优化 (Performance)",
            "📦 依赖更新 (Dependencies)",
            "♻️ 代码重构 (Code Refactoring)",
            "📚 文档更新 (Documentation)",
            "💎 代码格式 (Styles)",
            "✅ 测试 (Tests)",
            "👷 构建系统 (Build)",
            "🔧 CI配置 (CI)",
            "🎫 杂项 (Chores)",
            "⏪ 回滚 (Reverts)",
            "🔨 其他变更 (Other Changes)"
        ]

        for category in priority_order:
            if category in changes and changes[category]:
                md += f"### {category}\n\n"
                for item in changes[category]:
                    md += self._format_item(item)
                md += "\n"
        
        # 处理其他未在优先列表中的分类
        for category, items in changes.items():
            if category not in priority_order:
                md += f"### {category}\n\n"
                for item in items:
                    md += self._format_item(item)
                md += "\n"
                
        return md

    def _format_item(self, item):
        """格式化单个条目"""
        scope_str = f"**{item['scope']}**: " if item['scope'] else ""
        
        enhanced = item['enhanced_info']
        
        # 标题行标记
        tags = []
        if enhanced.get("breaking_change"):
            tags.append("💥 BREAKING")
        
        tags_str = " ".join([f"`{t}`" for t in tags])
        if tags_str:
            tags_str = " " + tags_str
        
        # 处理 Commit 链接
        hash_str = item['hash']
        url_template = self.config.get("commit_url_template", "")
        if url_template and "{hash}" in url_template:
             # 简单的防误触检查：如果是默认示例值，不生成链接（可选，或者假设用户知道自己在做什么）
             # 这里我们信任用户配置，只要非空且包含 {hash} 就替换
             commit_url = url_template.replace("{hash}", hash_str)
             hash_part = f"[{hash_str}]({commit_url})"
        else:
             hash_part = hash_str

        # 基础行
        md = f"- {scope_str}{item['description']}{tags_str} ({hash_part}) by @{item['author']}\n"
        
        # 附加信息 (Body)
        body = item['body'].strip()
        
        if enhanced.get("breaking_change"):
            md += f"  > ⚠️ **BREAKING CHANGE**: {enhanced['breaking_change']}\n"
            
        if body:
            lines = body.split('\n')
            for line in lines:
                line = line.strip()
                if not line:
                    continue
                
                # 忽略已经处理的 BREAKING CHANGE 行
                if "BREAKING CHANGE" in line:
                    continue
                    
                # 格式化特殊段落标题
                lower_line = line.lower()
                if lower_line.startswith(("example:", "usage:", "impact:", "solution:", "metrics:", "migration guide:")):
                    # 加粗冒号前的部分
                    key, val = line.split(':', 1)
                    md += f"  > **{key}**: {val.strip()}\n"
                else:
                    md += f"  > {line}\n"
                    
        return md

    def run(self):
        print(f"正在分析分支差异: 当前分支 [{self.get_current_branch()}] <-> 主分支 [{self.main_branch}] ...")
        
        commits = self.get_diff_commits()
        if not commits:
            print("未发现新的差异提交。")
            return

        print(f"发现 {len(commits)} 个新提交。")
        
        changes = self.parse_commits(commits)
        
        version = self.options.version or "Unreleased"
        
        new_content = self.generate_markdown(changes, version)
        
        if self.options.dry_run:
            print("\n--- 预览 CHANGELOG ---\n")
            print(new_content)
            print("--- 预览结束 ---")
            return

        existing_content = ""
        if os.path.exists(self.changelog_file):
            with open(self.changelog_file, 'r', encoding='utf-8') as f:
                existing_content = f.read()
        else:
            existing_content = "# Changelog\n\nAll notable changes to this project will be documented in this file.\n"

        header_match = re.match(r"(# .+?\n+)(.*)", existing_content, re.DOTALL)
        if header_match:
            final_content = header_match.group(1) + new_content + header_match.group(2)
        else:
            final_content = "# Changelog\n\n" + new_content + existing_content

        with open(self.changelog_file, 'w', encoding='utf-8') as f:
            f.write(final_content)
            
        print(f"✅ 成功更新 CHANGELOG.md")
        
        if self.options.commit:
            self._run_git(["add", "CHANGELOG.md"])
            self._run_git(["commit", "-m", f"docs: update CHANGELOG.md for {version}"])
            print("✅ 已自动提交 CHANGELOG.md")

def main():
    parser = argparse.ArgumentParser(description="Claude Code Agent - Changelog Generator")
    parser.add_argument("--dry-run", action="store_true", help="预览模式，不修改文件")
    parser.add_argument("--verbose", action="store_true", help="显示详细日志")
    parser.add_argument("--version", type=str, help="指定版本号 (例如 v1.0.0)")
    parser.add_argument("--commit", action="store_true", help="生成后自动提交")
    
    args = parser.parse_args()
    
    agent = ChangelogAgent(args)
    agent.run()

if __name__ == "__main__":
    main()
