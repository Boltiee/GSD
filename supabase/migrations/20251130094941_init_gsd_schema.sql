-- =====================================================================
--  GSD — Initial Schema v0.1
--  This migration creates all core tables + enums + RLS policies.
-- =====================================================================

-- =========================
-- ENUMS
-- =========================

create type task_status as enum ('pending', 'active', 'done', 'archived');
create type task_source as enum ('capture', 'routine', 'habit', 'ai', 'manual');
create type task_category as enum ('work', 'home', 'health', 'gym', 'family', 'self');
create type habit_frequency as enum ('daily', 'weekly', 'biweekly', 'monthly');
create type reflection_period as enum ('daily', 'weekly');

-- =========================
-- USERS PROFILE
-- =========================

create table users_profile (
  user_id uuid primary key references auth.users(id) on delete cascade,
  timezone text default 'Australia/Brisbane',
  onboarding_complete boolean default false,
  created_at timestamptz default now()
);

alter table users_profile enable row level security;

create policy "Users can view their own profile"
  on users_profile for select
  using (auth.uid() = user_id);

create policy "Users can insert their own profile"
  on users_profile for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own profile"
  on users_profile for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- =========================
-- CAPTURE TABLES
-- =========================

create table inbox_raw (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  source text not null,
  raw_text text not null,
  metadata jsonb,
  created_at timestamptz default now()
);

alter table inbox_raw enable row level security;

create policy "Users can CRUD their own raw captures"
  on inbox_raw
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


create table inbox_recommended (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  raw_id uuid references inbox_raw(id) on delete cascade,
  suggested_type text,
  suggested_title text,
  suggested_description text,
  suggested_do_on_date date,
  suggested_deadline_at timestamptz,
  suggested_impact text,
  suggested_mindset text,
  suggested_category task_category,
  goal_id uuid,
  initiative_id uuid,
  confidence numeric,
  ai_provider text,
  created_at timestamptz default now()
);

alter table inbox_recommended enable row level security;

create policy "Users can CRUD their own recommendations"
  on inbox_recommended
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- =========================
-- TASKS
-- =========================

create table tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),

  title text not null,
  notes text,
  status task_status default 'pending',
  source task_source default 'manual',
  category task_category,

  type text default 'task', -- task | habit | routine | reminder

  do_on_date date,
  deadline_at timestamptz,

  is_must_do_today boolean default false,

  generated_by_routine_id uuid, -- forward-declared, will add FK later

  ai_summary text,
  ai_tags jsonb,
  ai_suggested_next_actions jsonb,

  created_at timestamptz default now(),
  completed_at timestamptz
);

alter table tasks enable row level security;

create policy "Users can CRUD their own tasks"
  on tasks
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- =========================
-- HABITS
-- =========================

create table habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),

  title text not null,
  description text,
  frequency habit_frequency,
  target_count int,
  current_streak int default 0,
  longest_streak int default 0,
  last_completed_at timestamptz,

  ai_tags jsonb,
  ai_summary text,

  created_at timestamptz default now()
);

alter table habits enable row level security;

create policy "Users can CRUD their own habits"
  on habits
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


create table habit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  habit_id uuid references habits(id) on delete cascade,
  logged_at timestamptz default now()
);

alter table habit_logs enable row level security;

create policy "Users can CRUD their own habit logs"
  on habit_logs
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- =========================
-- ROUTINES
-- =========================

create table routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),

  title text not null,
  description text,
  recurrence_rule text not null, -- e.g. "weekly-Sun", "monthly-1", "6months"
  next_run_date date,

  template_title text,
  template_description text,

  ai_summary text,
  ai_tags jsonb,

  is_active boolean default true,
  created_at timestamptz default now()
);

alter table routines enable row level security;

create policy "Users can CRUD their own routines"
  on routines
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


create table routine_instances (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  routine_id uuid references routines(id) on delete cascade,
  run_date date,
  created_task_id uuid references tasks(id),
  created_at timestamptz default now()
);

alter table routine_instances enable row level security;

create policy "Users can CRUD their own routine instances"
  on routine_instances
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Now add the FK from tasks to routines
alter table tasks
  add constraint fk_tasks_routine
  foreign key (generated_by_routine_id)
  references routines(id)
  on delete set null;


-- =========================
-- REFLECTIONS
-- =========================

create table reflections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),

  period_type reflection_period,
  period_start date,
  period_end date,

  summary_text text,
  highlights jsonb,
  model_used text,
  input_metadata jsonb,

  created_at timestamptz default now()
);

alter table reflections enable row level security;

create policy "Users can CRUD their own reflections"
  on reflections
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- =========================
-- AI LOGGING
-- =========================

create table ai_calls (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),

  type text,
  provider text,
  model text,
  success boolean,
  error_message text,

  input_tokens int,
  output_tokens int,

  created_at timestamptz default now()
);

alter table ai_calls enable row level security;

create policy "Users can view their own ai logs"
  on ai_calls for select
  using (auth.uid() = user_id);

create policy "Users can insert their own ai logs"
  on ai_calls for insert
  with check (auth.uid() = user_id);


-- =========================
-- AUDIT LOGS (optional)
-- =========================

create table events_audit (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  event_type text,
  details jsonb,
  created_at timestamptz default now()
);

alter table events_audit enable row level security;

create policy "Users can insert their own events"
  on events_audit for insert
  with check (auth.uid() = user_id);

create policy "Users can view their own events"
  on events_audit for select
  using (auth.uid() = user_id);

