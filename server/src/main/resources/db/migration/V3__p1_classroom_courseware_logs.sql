create table if not exists classroom_tasks (
  id uuid primary key,
  classroom_id uuid references classrooms(id),
  title varchar(128) not null,
  description text,
  status varchar(32) not null default 'OPEN',
  due_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists courseware_play_records (
  id uuid primary key,
  courseware_id uuid references coursewares(id),
  teacher_id uuid references teachers(id),
  classroom_id uuid references classrooms(id),
  played_seconds int not null default 0,
  progress_percent int not null default 0,
  started_at timestamptz not null default now(),
  ended_at timestamptz
);

create table if not exists teacher_comments (
  id uuid primary key,
  teacher_id uuid references teachers(id),
  work_id uuid references works(id),
  original_text text,
  optimized_text text,
  style_name varchar(64),
  created_at timestamptz not null default now()
);

create index if not exists idx_coursewares_status on coursewares(status);
create index if not exists idx_coursewares_category on coursewares(category);
create index if not exists idx_play_records_started_at on courseware_play_records(started_at);
create index if not exists idx_parent_settings_parent_user on parent_settings(parent_user_id);
