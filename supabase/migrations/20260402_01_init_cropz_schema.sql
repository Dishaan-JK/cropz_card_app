-- Cropz Card initial backend schema
-- Safe to run multiple times where noted.

create extension if not exists pgcrypto;

create table if not exists public.user_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  device_id text not null,
  platform text not null,
  model text,
  app_version text,
  last_login_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, device_id)
);

create table if not exists public.user_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  device_id text not null,
  device_type text not null,
  device_model text,
  is_active boolean not null default true,
  last_seen_at timestamptz not null default now(),
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);

create unique index if not exists user_sessions_one_active_per_user
  on public.user_sessions(user_id)
  where is_active = true;

create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists cards_user_updated_idx
  on public.cards(user_id, updated_at desc);

alter table public.user_devices enable row level security;
alter table public.user_sessions enable row level security;
alter table public.cards enable row level security;

-- Basic owner-scoped policies
create policy if not exists "user_devices_owner_all"
on public.user_devices
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy if not exists "user_sessions_owner_read"
on public.user_sessions
for select
using (auth.uid() = user_id);

create policy if not exists "user_sessions_owner_insert"
on public.user_sessions
for insert
with check (auth.uid() = user_id);

create policy if not exists "user_sessions_owner_update"
on public.user_sessions
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy if not exists "cards_owner_all"
on public.cards
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Session-aware helper (uses custom header x-device-session-id)
create or replace function public.current_session_is_active()
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.user_sessions s
    where s.user_id = auth.uid()
      and s.id::text = coalesce(
        (current_setting('request.headers', true)::json ->> 'x-device-session-id'),
        ''
      )
      and s.is_active = true
  );
$$;

-- Tighten cards policies to enforce active-session guard
drop policy if exists "cards_owner_all" on public.cards;

create policy "cards_select_active_session"
on public.cards
for select
using (auth.uid() = user_id and public.current_session_is_active());

create policy "cards_insert_active_session"
on public.cards
for insert
with check (auth.uid() = user_id and public.current_session_is_active());

create policy "cards_update_active_session"
on public.cards
for update
using (auth.uid() = user_id and public.current_session_is_active())
with check (auth.uid() = user_id and public.current_session_is_active());

create policy "cards_delete_active_session"
on public.cards
for delete
using (auth.uid() = user_id and public.current_session_is_active());