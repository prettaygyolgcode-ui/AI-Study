# AI 课堂后台管理系统开发文档

> 面向后台、前端、iOS、Android 开发人员。本文档定义后台管理系统的技术栈、模块边界、数据模型、API、部署方式和开发优先级。

**目标：** 建设一套供 Web 管理后台、iOS、Android、网页课堂端共用的业务后台，支撑机构、老师、课件、AI 卡片、作品审核、家长控制和数据记录。

**推荐架构：** 模块化单体后端优先，避免第一期过早拆微服务。Web 后台和多端 App 通过统一 REST API 访问 Java 后端；课件转换、AI 调用记录、统计聚合通过异步任务处理。

**技术栈：** Next.js + TypeScript + Spring Boot + PostgreSQL + Redis + MinIO/OSS + Docker Compose。

---

## 1. 总体范围

### 1.1 服务对象

- Web 后台：运营、机构管理员、老师使用。
- iOS App：学生端、家长设置、老师入口。
- Android App：与 iOS 使用同一套 API。
- 网页课堂端：与 App 使用同一套课件、作品、AI 配置和登录体系。

### 1.2 后台核心能力

- 机构管理：机构账号、合作状态、班级数量、老师数量。
- 教师管理：老师权限开通、绑定机构、查看使用记录。
- 课件管理：上传课件、配置年龄段、课程分类、上下架状态。
- AI 卡片库：管理 AI 朋友、创作卡片、角色提示词、安全限制。
- 作品管理：查看、审核、驳回、推荐、下架。
- 数据记录：登录、AI 调用、创作、作品发布、点赞评分、课件播放、老师点评。

---

## 2. 技术选型

### 2.1 后台前端

**选型：** Next.js + TypeScript + Tailwind CSS + shadcn/ui + TanStack Query。

**原因：**

- 管理后台以表格、表单、筛选、详情页为主，React 生态成熟。
- TypeScript 便于与 OpenAPI 类型生成配合。
- shadcn/ui 适合快速搭建统一风格的管理后台组件。
- TanStack Query 负责接口缓存、加载状态、错误重试。

### 2.2 后端核心服务

**选型：** Java 21 + Spring Boot + Spring Security + MyBatis-Plus + Flyway。

**原因：**

- 多端共用后台，后端会长期承担权限、审核、审计、额度、日志和异步任务，Java 更适合长期稳定维护。
- Spring Security 对 RBAC、JWT、接口鉴权、方法级权限控制成熟。
- MyBatis-Plus 对后台管理系统的复杂查询、分页、条件筛选更可控。
- Flyway 保证数据库结构可迁移、可回滚、可审计。

### 2.3 基础设施

- 主数据库：PostgreSQL。
- 缓存和队列：Redis。
- 本地对象存储：MinIO。
- 生产对象存储：阿里云 OSS。
- 课件转换：LibreOffice Headless，将 PPT/PPTX 转 PDF 或图片序列。
- 本地部署：Docker Compose。
- 生产初期：阿里云 ECS + Docker Compose + Nginx + HTTPS。
- 生产中后期：阿里云 RDS PostgreSQL + 云 Redis + OSS；规模上来后迁 ACK。

---

## 3. 推荐仓库结构

```text
ai-classroom-platform/
  admin-web/                 # Next.js 后台管理前端
  server/                    # Spring Boot 后端
    src/main/java/
      com/aiclassroom/
        common/              # 通用异常、分页、响应体、工具
        auth/                # 登录、JWT、权限
        organization/        # 机构管理
        teacher/             # 教师管理
        classroom/           # 班级和学生绑定
        courseware/          # 课件管理和播放记录
        aiasset/             # AI 朋友、创作卡、提示词、安全规则
        work/                # 作品、审核、推荐、下架
        parent/              # 家长设置
        telemetry/           # 数据记录和审计日志
        file/                # 文件上传、MinIO/OSS 适配
        appapi/              # iOS/Android/网页课堂端 API
    src/main/resources/
      db/migration/          # Flyway SQL
  worker/                    # 可选：后续独立课件转换/AI异步任务服务
  infra/
    docker-compose.yml
    nginx/
    minio/
  docs/
    backend/
```

第一期可以不单独创建 `worker/`，先在 `server` 内用 Spring 异步任务或定时任务实现。课件转换、AI 批量点评压力变大后，再拆独立 worker。

---

## 4. 角色和权限

| 角色 | 说明 | 核心权限 |
| --- | --- | --- |
| SUPER_ADMIN | 平台超级管理员 | 所有机构、老师、课件、AI 卡片、作品、日志 |
| OPS_ADMIN | 平台运营 | 机构、老师、课件、作品、AI 卡片管理 |
| ORG_ADMIN | 机构管理员 | 本机构老师、班级、学生绑定、课件使用数据 |
| TEACHER | 老师 | 我的课程、班级管理、任务完成、作品审批、AI 点评 |
| PARENT | 家长 | 家长设置、孩子记录、公开发布开关 |
| STUDENT | 学生 | 学生端创作、AI 对话、广场互动 |

权限实现建议：

- JWT 内包含 `userId`、`role`、`organizationId`、`teacherId`、`studentId`。
- 后台接口使用 RBAC，必要接口加数据范围过滤。
- 老师只能访问自己机构或自己班级的数据。
- 家长只能访问绑定手机号下孩子的数据。

---

## 5. 核心数据模型

### 5.1 账号与机构

```sql
users(
  id uuid primary key,
  phone varchar(32) unique,
  display_name varchar(64),
  role varchar(32),
  status varchar(32),
  created_at timestamptz,
  updated_at timestamptz
)

organizations(
  id uuid primary key,
  name varchar(128),
  contact_name varchar(64),
  contact_phone varchar(32),
  cooperation_status varchar(32),
  classroom_count int,
  teacher_count int,
  created_at timestamptz,
  updated_at timestamptz
)

teachers(
  id uuid primary key,
  user_id uuid references users(id),
  organization_id uuid references organizations(id),
  authorized boolean,
  authorized_at timestamptz,
  last_active_at timestamptz
)
```

### 5.2 班级与学生绑定

```sql
classrooms(
  id uuid primary key,
  organization_id uuid references organizations(id),
  teacher_id uuid references teachers(id),
  name varchar(128),
  age_band varchar(32),
  status varchar(32),
  created_at timestamptz
)

students(
  id uuid primary key,
  parent_user_id uuid references users(id),
  nickname varchar(64),
  age_band varchar(32),
  created_at timestamptz
)

classroom_students(
  classroom_id uuid references classrooms(id),
  student_id uuid references students(id),
  parent_phone varchar(32),
  bind_status varchar(32),
  primary key(classroom_id, student_id)
)
```

### 5.3 课件

```sql
coursewares(
  id uuid primary key,
  title varchar(128),
  age_band varchar(32),
  category varchar(64),
  status varchar(32),
  original_file_url text,
  converted_asset_url text,
  conversion_status varchar(32),
  duration_minutes int,
  created_by uuid references users(id),
  created_at timestamptz,
  updated_at timestamptz
)

courseware_play_records(
  id uuid primary key,
  courseware_id uuid references coursewares(id),
  teacher_id uuid references teachers(id),
  classroom_id uuid references classrooms(id),
  started_at timestamptz,
  ended_at timestamptz,
  played_seconds int,
  progress numeric(5,2),
  client_type varchar(32)
)
```

### 5.4 AI 卡片库

```sql
ai_friends(
  id uuid primary key,
  name varchar(64),
  type varchar(32),
  icon_url text,
  description text,
  role_prompt text,
  safety_rule_id uuid,
  classroom_assignable boolean,
  status varchar(32),
  sort_order int
)

creation_cards(
  id uuid primary key,
  type varchar(32),
  name varchar(64),
  icon_url text,
  prompt_template text,
  safety_rule_id uuid,
  status varchar(32),
  sort_order int
)

safety_rules(
  id uuid primary key,
  name varchar(64),
  blocked_topics jsonb,
  age_limits jsonb,
  moderation_policy jsonb,
  status varchar(32)
)
```

### 5.5 作品与审核

```sql
works(
  id uuid primary key,
  student_id uuid references students(id),
  type varchar(32),
  title varchar(128),
  content_url text,
  preview_text text,
  prompt jsonb,
  status varchar(32),
  publish_status varchar(32),
  score numeric(4,1),
  like_count int,
  recommended boolean,
  created_at timestamptz,
  updated_at timestamptz
)

work_reviews(
  id uuid primary key,
  work_id uuid references works(id),
  reviewer_id uuid references users(id),
  action varchar(32),
  reason text,
  reviewed_at timestamptz
)

work_interactions(
  id uuid primary key,
  work_id uuid references works(id),
  user_id uuid references users(id),
  interaction_type varchar(32),
  created_at timestamptz
)
```

### 5.6 设置与日志

```sql
parent_settings(
  id uuid primary key,
  parent_user_id uuid references users(id),
  student_id uuid references students(id),
  compute_budget_limit int,
  daily_minutes_limit int,
  enabled_ai_features jsonb,
  allow_public_publishing boolean,
  auto_narration_enabled boolean,
  voice_input_enabled boolean,
  updated_at timestamptz
)

audit_logs(
  id uuid primary key,
  actor_user_id uuid,
  action varchar(64),
  target_type varchar(64),
  target_id uuid,
  metadata jsonb,
  ip_address varchar(64),
  user_agent text,
  created_at timestamptz
)

ai_call_logs(
  id uuid primary key,
  user_id uuid,
  student_id uuid,
  feature_type varchar(32),
  provider varchar(32),
  model varchar(64),
  prompt_tokens int,
  completion_tokens int,
  cost_amount numeric(10,4),
  status varchar(32),
  created_at timestamptz
)
```

---

## 6. API 设计

### 6.1 通用规范

- API 前缀：`/api/v1`
- 后台接口：`/api/v1/admin/**`
- 多端 App 接口：`/api/v1/app/**`
- 返回结构：

```json
{
  "code": "OK",
  "message": "success",
  "data": {}
}
```

- 分页结构：

```json
{
  "items": [],
  "page": 1,
  "pageSize": 20,
  "total": 100
}
```

### 6.2 认证接口

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/api/v1/auth/sms/send` | 发送验证码 |
| POST | `/api/v1/auth/sms/login` | 手机号验证码登录 |
| POST | `/api/v1/auth/logout` | 退出登录 |
| GET | `/api/v1/auth/me` | 当前用户信息 |

### 6.3 后台管理接口

| 模块 | 核心接口 |
| --- | --- |
| 机构 | `GET/POST/PUT /admin/organizations` |
| 老师 | `GET /admin/teachers`、`POST /admin/teachers/{id}/authorize` |
| 课件 | `POST /admin/coursewares/upload`、`PUT /admin/coursewares/{id}/status` |
| AI 卡片 | `GET/POST/PUT /admin/ai-friends`、`GET/POST/PUT /admin/creation-cards` |
| 作品 | `GET /admin/works`、`POST /admin/works/{id}/approve`、`POST /admin/works/{id}/reject` |
| 日志 | `GET /admin/audit-logs`、`GET /admin/ai-call-logs` |

### 6.4 App 共用接口

| 模块 | 核心接口 |
| --- | --- |
| 首页配置 | `GET /app/bootstrap` |
| AI 朋友 | `GET /app/ai-friends`、`POST /app/ai-friends/{id}/favorite` |
| 创作 | `POST /app/works`、`GET /app/works/my`、`POST /app/works/{id}/submit-review` |
| 广场 | `GET /app/plaza/works`、`POST /app/plaza/works/{id}/like` |
| 家长设置 | `GET/PUT /app/parent/settings` |
| 老师端 | `GET /app/teacher/courses`、`POST /app/teacher/works/{id}/approve` |

---

## 7. 关键业务流程

### 7.1 作品发布审核

1. 学生端创建作品，状态为 `PENDING_REVIEW`。
2. 如果家长关闭公开发布，接口拒绝提交公开审核。
3. 老师或运营后台进入作品管理。
4. 审核通过后，作品 `publish_status = PUBLISHED`，进入广场。
5. 驳回后，作品 `status = REJECTED`，记录驳回原因。
6. 推荐作品只改变 `recommended = true`，不改变发布状态。
7. 下架作品只改变 `publish_status = OFFLINE`，保留审核记录。

### 7.2 课件上传和播放

1. 后台上传 PPT/PPTX/PDF。
2. 文件进入 MinIO，生成 `original_file_url`。
3. 创建课件记录，`conversion_status = PENDING`。
4. Worker 调用 LibreOffice 转 PDF 或图片序列。
5. 转换完成后写入 `converted_asset_url`，`conversion_status = SUCCESS`。
6. iOS/Android/网页课堂端只播放转换后的 PDF/图片/H5，不直接解析 PPT。
7. 播放开始、结束、进度变化写入 `courseware_play_records`。

### 7.3 AI 卡片配置下发

1. 后台维护 AI 朋友、创作卡、角色提示词、安全规则。
2. App 启动时调用 `/app/bootstrap`。
3. 后端按年龄段、机构、班级返回可用卡片。
4. 被下架卡片不返回给 App，但历史作品保留原始类型。

---

## 8. Docker 本地部署

### 8.1 服务列表

```yaml
services:
  admin-web:
    build: ../admin-web
    ports:
      - "3000:3000"

  server:
    build: ../server
    ports:
      - "8080:8080"
    depends_on:
      - postgres
      - redis
      - minio

  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: ai_classroom
      POSTGRES_USER: ai_classroom
      POSTGRES_PASSWORD: ai_classroom_dev
    ports:
      - "5432:5432"

  redis:
    image: redis:7
    ports:
      - "6379:6379"

  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minio
      MINIO_ROOT_PASSWORD: minio123456
    ports:
      - "9000:9000"
      - "9001:9001"
```

### 8.2 环境变量

```text
SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/ai_classroom
SPRING_DATASOURCE_USERNAME=ai_classroom
SPRING_DATASOURCE_PASSWORD=ai_classroom_dev
REDIS_HOST=redis
JWT_SECRET=local-dev-change-me
OBJECT_STORAGE_PROVIDER=minio
MINIO_ENDPOINT=http://minio:9000
MINIO_ACCESS_KEY=minio
MINIO_SECRET_KEY=minio123456
```

---

## 9. 开发优先级

### P0：后台可运行 + 支撑当前 App 核心闭环

目标：本地 Docker 能启动后台，iOS/Android/Web 能共用基础接口。

- 项目骨架：`admin-web`、`server`、`infra/docker-compose.yml`。
- 认证鉴权：手机号验证码模拟登录、JWT、RBAC。
- 基础数据：机构、老师、学生、班级。
- AI 配置：AI 朋友、创作卡、上下架。
- 作品管理：作品列表、详情、审核、驳回、推荐、下架。
- App Bootstrap：向客户端下发 AI 朋友、创作卡、用户、家长设置。
- 文件上传：MinIO 上传，课件原文件保存。
- 数据库迁移：Flyway 初始化表结构。
- 测试：后端集成测试覆盖登录、作品审核、课件上传、配置下发。

验收标准：

- `docker compose up` 后可以打开后台登录页。
- 后台能创建机构、授权老师、上传课件、配置 AI 卡片。
- App 能通过 `/app/bootstrap` 拉到配置。
- 作品能从待审核变为已发布并出现在广场接口。

### P1：课件转换 + 老师工作台 + 数据记录

目标：后台开始支撑真实课堂使用和运营追踪。

- 课件转换：PPT/PPTX 转 PDF 或图片序列。
- 课程分类：年龄段、课程分类、上下架。
- 老师工作台：我的课程、班级管理、学生绑定、任务完成情况。
- 播放记录：记录老师、班级、播放时长、播放进度。
- 数据日志：登录、AI 调用、创作、发布、点赞、课件播放、老师点评。
- 家长设置：额度、时长、AI 功能、公开发布、语音输入、自动朗读。
- 后台筛选：作品、老师、课件、日志均支持分页和多条件筛选。

验收标准：

- PPT 上传后能生成可播放资源。
- 老师能按年龄段查看课件并记录播放。
- 家长设置能影响 App 端发布和 AI 功能入口。
- 日志页面能按用户、时间、类型筛选。

### P2：AI 点评、安全策略、统计看板

目标：完善 AI 能力治理和运营分析。

- AI 点评：单个点评、批量点评、老师风格模板。
- 安全规则：角色提示词、安全限制、年龄限制、敏感主题。
- 额度控制：按学生、家长、机构限制 AI 调用额度。
- 统计看板：机构活跃、老师使用、课件播放、作品发布、AI 消耗。
- 内容治理：作品推荐、下架、违规原因、审核记录追踪。

验收标准：

- 老师能生成 AI 点评并编辑发布。
- AI 调用能被记录并计入额度。
- 运营能看到核心数据趋势。

### P3：生产增强和规模化

目标：准备生产长期运行。

- 阿里云 OSS 替换 MinIO。
- 阿里云 RDS PostgreSQL、云 Redis。
- Nginx HTTPS、域名、日志归档。
- OpenAPI 自动生成客户端 SDK。
- 监控告警：健康检查、接口耗时、错误率、队列堆积。
- 备份策略：数据库备份、对象存储生命周期。
- 如并发上升，迁移到 ACK。

---

## 10. 测试要求

### 10.1 后端测试

- 单元测试：Service 层业务规则。
- 集成测试：Controller + PostgreSQL Testcontainers。
- 权限测试：不同角色访问同一接口应返回不同结果。
- 文件测试：上传文件、课件转换状态流转。
- 审计测试：关键操作必须写入 `audit_logs`。

### 10.2 前端测试

- 表单校验：机构、老师、课件、AI 卡片、作品驳回。
- 列表筛选：分页、状态筛选、关键词搜索。
- 权限展示：不同角色菜单不同。
- E2E：登录、上传课件、审核作品、配置 AI 卡片。

### 10.3 App 联调测试

- iOS、Android、网页端都使用同一套 `/app/**` API。
- App 端不直接依赖后台管理接口。
- 后台字段变更必须先更新 OpenAPI，再更新客户端 DTO。

---

## 11. 阿里云迁移方案

### 阶段 1：本地开发

- Docker Compose 运行所有服务。
- MinIO 代替 OSS。
- PostgreSQL 和 Redis 使用本地容器。

### 阶段 2：测试环境

- 阿里云 ECS 运行 Docker Compose。
- 使用 Nginx 暴露 `admin-web` 和 `server`。
- 数据库仍可容器化，降低早期成本。

### 阶段 3：生产初期

- ECS 运行 `admin-web`、`server`、`worker`。
- 数据库迁移到阿里云 RDS PostgreSQL。
- Redis 迁移到阿里云 Redis。
- 文件迁移到阿里云 OSS。
- 日志写入阿里云 SLS。

### 阶段 4：规模化

- 服务迁移到 ACK。
- 镜像进入 ACR。
- 使用 SLB、HPA、SLS、云监控。

---

## 12. 开发顺序建议

1. 建 `server` Spring Boot 项目和 `admin-web` Next.js 项目。
2. 建 `infra/docker-compose.yml`，确保本地一键启动。
3. 写 Flyway 初始表：用户、机构、老师、学生、班级、作品、课件、AI 配置。
4. 做认证和 RBAC。
5. 做作品管理，因为它直接支撑当前 App 的审核和广场。
6. 做 AI 卡片库，因为它决定客户端配置下发。
7. 做课件管理和文件上传。
8. 做老师管理和班级绑定。
9. 做数据记录和日志查询。
10. 做课件转换和 AI 点评。

---

## 13. 不建议第一期做的事

- 不要第一期拆微服务。
- 不要让 App 直接播放 PPT 原文件。
- 不要让后台前端直接访问数据库。
- 不要把运营后台接口和 App 接口混用。
- 不要把提示词、安全规则写死在客户端。
- 不要先做复杂 BI，看板可以 P2 再完善。

