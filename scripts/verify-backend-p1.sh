#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "server/src/main/resources/db/migration/V3__p1_classroom_courseware_logs.sql"
  "server/src/main/java/com/aiclassroom/courseware/CoursewareController.java"
  "server/src/main/java/com/aiclassroom/teacherworkspace/TeacherWorkspaceController.java"
  "server/src/main/java/com/aiclassroom/parent/ParentSettingsController.java"
  "server/src/main/java/com/aiclassroom/telemetry/TelemetryController.java"
  "admin-web/app/coursewares/page.tsx"
  "admin-web/app/teacher-workspace/page.tsx"
  "admin-web/app/parent-settings/page.tsx"
  "admin-web/app/logs/page.tsx"
  "admin-web/components/CoursewarePanel.tsx"
  "admin-web/components/TeacherWorkspacePanel.tsx"
  "admin-web/components/ParentSettingsPanel.tsx"
  "admin-web/components/LogsPanel.tsx"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "missing required file: $file" >&2
    exit 1
  fi
done

grep -q "/api/v1/admin/coursewares" server/src/main/java/com/aiclassroom/courseware/CoursewareController.java
grep -q "/api/v1/teacher/workspace" server/src/main/java/com/aiclassroom/teacherworkspace/TeacherWorkspaceController.java
grep -q "/api/v1/admin/parent-settings" server/src/main/java/com/aiclassroom/parent/ParentSettingsController.java
grep -q "/api/v1/admin/logs" server/src/main/java/com/aiclassroom/telemetry/TelemetryController.java
grep -q "courseware_play_records" server/src/main/resources/db/migration/V3__p1_classroom_courseware_logs.sql
grep -q "课件管理" admin-web/components/AdminShell.tsx
grep -q "老师工作台" admin-web/components/AdminShell.tsx
grep -q "家长设置" admin-web/components/AdminShell.tsx
grep -q "数据日志" admin-web/components/AdminShell.tsx

echo "Backend P1 static verification passed."
