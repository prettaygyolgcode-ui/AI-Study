create table if not exists users (
  id uuid primary key,
  phone varchar(32) unique,
  display_name varchar(64) not null,
  role varchar(32) not null,
  status varchar(32) not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists organizations (
  id uuid primary key,
  name varchar(128) not null,
  contact_name varchar(64),
  contact_phone varchar(32),
  cooperation_status varchar(32) not null default 'ACTIVE',
  classroom_count int not null default 0,
  teacher_count int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists teachers (
  id uuid primary key,
  user_id uuid references users(id),
  organization_id uuid references organizations(id),
  name varchar(64) not null,
  phone varchar(32) not null,
  authorized boolean not null default false,
  authorized_at timestamptz,
  last_active_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists classrooms (
  id uuid primary key,
  organization_id uuid references organizations(id),
  teacher_id uuid references teachers(id),
  name varchar(128) not null,
  age_band varchar(32) not null,
  status varchar(32) not null default 'ACTIVE',
  created_at timestamptz not null default now()
);

create table if not exists students (
  id uuid primary key,
  parent_user_id uuid references users(id),
  nickname varchar(64) not null,
  age_band varchar(32),
  created_at timestamptz not null default now()
);

create table if not exists classroom_students (
  classroom_id uuid references classrooms(id),
  student_id uuid references students(id),
  parent_phone varchar(32) not null,
  bind_status varchar(32) not null default 'ACTIVE',
  primary key(classroom_id, student_id)
);

create table if not exists coursewares (
  id uuid primary key,
  title varchar(128) not null,
  age_band varchar(32) not null,
  category varchar(64) not null,
  status varchar(32) not null default 'DRAFT',
  original_file_url text,
  converted_asset_url text,
  conversion_status varchar(32) not null default 'PENDING',
  duration_minutes int not null default 0,
  created_by uuid references users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists ai_friends (
  id uuid primary key,
  name varchar(64) not null,
  type varchar(32) not null default 'general',
  icon_url text,
  description text,
  role_prompt text not null,
  safety_rule_id uuid,
  classroom_assignable boolean not null default true,
  status varchar(32) not null default 'ACTIVE',
  sort_order int not null default 0
);

create table if not exists creation_cards (
  id uuid primary key,
  type varchar(32) not null,
  name varchar(64) not null,
  icon_url text,
  prompt_template text not null,
  safety_rule_id uuid,
  status varchar(32) not null default 'ACTIVE',
  sort_order int not null default 0
);

create table if not exists safety_rules (
  id uuid primary key,
  name varchar(64) not null,
  blocked_topics jsonb not null default '[]'::jsonb,
  age_limits jsonb not null default '{}'::jsonb,
  moderation_policy jsonb not null default '{}'::jsonb,
  status varchar(32) not null default 'ACTIVE'
);

create table if not exists works (
  id uuid primary key,
  student_id uuid references students(id),
  type varchar(32) not null,
  title varchar(128) not null,
  content_url text,
  preview_text text,
  prompt jsonb not null default '{}'::jsonb,
  status varchar(32) not null default 'PENDING_REVIEW',
  publish_status varchar(32) not null default 'PRIVATE',
  score numeric(4,1) not null default 0,
  like_count int not null default 0,
  recommended boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists work_reviews (
  id uuid primary key,
  work_id uuid references works(id),
  reviewer_id uuid references users(id),
  action varchar(32) not null,
  reason text,
  reviewed_at timestamptz not null default now()
);

create table if not exists parent_settings (
  id uuid primary key,
  parent_user_id uuid references users(id),
  student_id uuid references students(id),
  compute_budget_limit int not null default 100,
  daily_minutes_limit int not null default 60,
  enabled_ai_features jsonb not null default '[]'::jsonb,
  allow_public_publishing boolean not null default true,
  auto_narration_enabled boolean not null default true,
  voice_input_enabled boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists audit_logs (
  id uuid primary key,
  actor_user_id uuid,
  action varchar(64) not null,
  target_type varchar(64) not null,
  target_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  ip_address varchar(64),
  user_agent text,
  created_at timestamptz not null default now()
);

create table if not exists ai_call_logs (
  id uuid primary key,
  user_id uuid,
  student_id uuid,
  feature_type varchar(32) not null,
  provider varchar(32),
  model varchar(64),
  prompt_tokens int not null default 0,
  completion_tokens int not null default 0,
  cost_amount numeric(10,4) not null default 0,
  status varchar(32) not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_works_status on works(status);
create index if not exists idx_works_publish_status on works(publish_status);
create index if not exists idx_coursewares_age_band on coursewares(age_band);
create index if not exists idx_audit_logs_created_at on audit_logs(created_at);
