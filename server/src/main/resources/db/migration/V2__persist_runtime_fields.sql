alter table works
  add column if not exists author_name varchar(64) not null default '学生';

alter table works
  alter column student_id drop not null;
