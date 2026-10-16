-- Keep the Dharma Alive: Idea Circles
-- Paste this whole file into Supabase: SQL Editor -> New query -> Run.
-- It adds two tables and touches nothing else. Safe to run more than once.
--
-- Visitors (the public "anon" key) can ADD rows but can never READ them,
-- so nobody can see anyone else's email. You read the results in the
-- Supabase Table Editor, or export them as CSV.

create extension if not exists pgcrypto;

-- Saturday: one row per idea someone submits.
create table if not exists ic_ideas (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  idea       text not null check (char_length(idea) between 3 and 2000),
  role       text not null check (role in ('lead', 'co-lead', 'committee', 'none')),
  name       text check (name is null or char_length(name) <= 200),
  email      text check (email is null or char_length(email) <= 320),
  -- Anything but 'none' needs an email so we can follow up.
  constraint ic_ideas_email_needed check (role = 'none' or email is not null)
);

-- Sunday: one row per idea a person signs up for.
create table if not exists ic_signups (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  idea_id    text not null check (char_length(idea_id) <= 100),
  idea_title text check (idea_title is null or char_length(idea_title) <= 300),
  choice     text not null check (choice in ('lead', 'co-lead', 'join')),
  name       text not null check (char_length(name) between 1 and 200),
  email      text not null check (char_length(email) between 3 and 320)
);

alter table ic_ideas   enable row level security;
alter table ic_signups enable row level security;

-- Insert only. There is deliberately no select, update or delete policy,
-- so the public key cannot read, change or remove anything.
drop policy if exists "anyone can add an idea" on ic_ideas;
create policy "anyone can add an idea" on ic_ideas
  for insert to anon with check (true);

drop policy if exists "anyone can sign up" on ic_signups;
create policy "anyone can sign up" on ic_signups
  for insert to anon with check (true);

grant insert on ic_ideas   to anon;
grant insert on ic_signups to anon;
