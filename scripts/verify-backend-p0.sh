#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "server/pom.xml"
  "server/Dockerfile"
  "server/src/main/java/com/aiclassroom/AiClassroomApplication.java"
  "server/src/main/java/com/aiclassroom/auth/AuthController.java"
  "server/src/main/java/com/aiclassroom/organization/OrganizationController.java"
  "server/src/main/java/com/aiclassroom/teacher/TeacherController.java"
  "server/src/main/java/com/aiclassroom/aiasset/AiAssetController.java"
  "server/src/main/java/com/aiclassroom/work/WorkController.java"
  "server/src/main/java/com/aiclassroom/file/FileController.java"
  "server/src/main/java/com/aiclassroom/appapi/AppBootstrapController.java"
  "server/src/main/resources/db/migration/V1__init_p0_schema.sql"
  "admin-web/package.json"
  "admin-web/app/page.tsx"
  "admin-web/app/accounts/page.tsx"
  "admin-web/app/works/page.tsx"
  "admin-web/app/ai-assets/page.tsx"
  "admin-web/components/AdminShell.tsx"
  "admin-web/components/AccountsPanel.tsx"
  "admin-web/lib/api.ts"
  "admin-web/lib/auth.ts"
  "admin-web/Dockerfile"
  "infra/docker-compose.yml"
  "infra/nginx/nginx.conf"
  "server/src/main/java/com/aiclassroom/account/AccountController.java"
  "server/src/main/java/com/aiclassroom/account/UserAccount.java"
  "server/src/main/java/com/aiclassroom/common/DatabasePage.java"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "missing required file: $file" >&2
    exit 1
  fi
done

grep -q "spring-boot-starter-security" server/pom.xml
grep -q "flyway-core" server/pom.xml
grep -q "mybatis-plus-spring-boot3-starter" server/pom.xml
grep -q "POST /api/v1/auth/sms/login" server/src/main/java/com/aiclassroom/auth/AuthController.java
grep -q "/api/v1/auth/admin/sms/login" server/src/main/java/com/aiclassroom/auth/AuthController.java
grep -q "/api/v1/app/bootstrap" server/src/main/java/com/aiclassroom/appapi/AppBootstrapController.java
grep -q "approve" server/src/main/java/com/aiclassroom/work/WorkController.java
grep -q "reject" server/src/main/java/com/aiclassroom/work/WorkController.java
grep -q "JdbcTemplate" server/src/main/java/com/aiclassroom/work/WorkController.java
grep -q "JdbcTemplate" server/src/main/java/com/aiclassroom/aiasset/AiAssetController.java
grep -q "JdbcTemplate" server/src/main/java/com/aiclassroom/auth/AuthController.java
grep -q "organizations" server/src/main/resources/db/migration/V1__init_p0_schema.sql
grep -q "works" server/src/main/resources/db/migration/V1__init_p0_schema.sql
grep -q "ai_friends" server/src/main/resources/db/migration/V1__init_p0_schema.sql
grep -q "coursewares" server/src/main/resources/db/migration/V1__init_p0_schema.sql
grep -q "后台账号" admin-web/components/AccountsPanel.tsx
grep -q "老师账号" admin-web/components/AccountsPanel.tsx
grep -q "家长账号" admin-web/components/AccountsPanel.tsx
grep -q "expiresAt" admin-web/lib/auth.ts
grep -q "AdminShell" admin-web/app/layout.tsx
if grep -q 'href="/login"' admin-web/app/layout.tsx; then
  echo "login nav should not appear in admin shell" >&2
  exit 1
fi
if rg -q "InMemoryStore" server/src/main/java --glob '!com/aiclassroom/common/InMemoryStore.java'; then
  echo "controllers must not use InMemoryStore" >&2
  exit 1
fi
grep -q "postgres:" infra/docker-compose.yml
grep -q "redis:" infra/docker-compose.yml
grep -q "minio:" infra/docker-compose.yml
grep -q "admin-web:" infra/docker-compose.yml
grep -q "server:" infra/docker-compose.yml

echo "Backend P0 static verification passed."
