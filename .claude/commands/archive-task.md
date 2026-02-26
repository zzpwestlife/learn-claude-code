<command>
  <name>archive-task</name>
  <description>Archives current task planning files (task_plan.md, findings.md) to .claude/archive/plans/</description>
  <usage>
    /archive-task
  </usage>
  <implementation>
    <run>
      .claude/skills/planning-with-files/scripts/archive-task.sh
    </run>
  </implementation>
</command>
