-- Idea Circles, step 2: the Ideas tab (see everyone's ideas, like or join them).
-- Paste this whole file into Supabase: SQL Editor -> New query -> Run.
-- Run schema.sql first. Safe to run more than once.
--
-- What visitors can see: idea text, when it was shared, and like/join counts.
-- What they never see: anyone's name or email.

-- Lets you hide spam or duplicates: tick "hidden" on a row in the Table Editor.
alter table ic_ideas add column if not exists hidden boolean not null default false;

-- One row per like or join.
create table if not exists ic_reactions (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  idea_id    uuid not null references ic_ideas(id) on delete cascade,
  kind       text not null check (kind in ('like', 'join')),
  name       text check (name is null or char_length(name) <= 200),
  email      text check (email is null or char_length(email) <= 320),
  -- Joining needs a way to reach you; liking doesn't.
  constraint ic_reactions_join_needs_email check (kind = 'like' or (email is not null and name is not null))
);

alter table ic_reactions enable row level security;

drop policy if exists "anyone can like or join" on ic_reactions;
create policy "anyone can like or join" on ic_reactions
  for insert to anon with check (true);

grant insert on ic_reactions to anon;

-- The public list. It shows only safe columns, so visitors can read it
-- while the tables underneath (with names and emails) stay unreadable.
create or replace view ic_ideas_public as
  select i.id,
         i.created_at,
         i.idea,
         count(r.id) filter (where r.kind = 'like') as likes,
         count(r.id) filter (where r.kind = 'join') as joins
  from ic_ideas i
  left join ic_reactions r on r.idea_id = i.id
  where not i.hidden
  group by i.id;

grant select on ic_ideas_public to anon;
