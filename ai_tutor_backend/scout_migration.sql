-- 1. FIX DELETION
-- Allow users to delete their own chat sessions
drop policy if exists "Users can delete own sessions" on chat_sessions;
create policy "Users can delete own sessions"
on chat_sessions for delete
using (auth.uid() = user_id);

-- 2. SCOUT SCHEMA
-- Add student_code to the public users table so students can share it
alter table users add column if not exists student_code text unique;

-- Create table linking Scouts (Parents) to Students
create table if not exists scout_students (
  id uuid primary key default gen_random_uuid(),
  scout_id uuid references users(id) not null,
  student_id uuid references users(id) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(scout_id, student_id)
);

-- Enable RLS
alter table scout_students enable row level security;

-- Scouts can see who they are monitoring
create policy "Scouts can view their links"
on scout_students for select
using (auth.uid() = scout_id);

-- 3. SCOUT ACCESS TO SESSIONS
-- Allow Scouts to view sessions of students they are linked to
drop policy if exists "Users can view own sessions" on chat_sessions;

create policy "Users and Scouts can view sessions"
on chat_sessions for select
using (
  auth.uid() = user_id 
  OR 
  exists (
    select 1 from scout_students 
    where scout_students.scout_id = auth.uid() 
    and scout_students.student_id = chat_sessions.user_id
  )
);

-- 4. MESSAGES ACCESS
-- Similar logic for messages (if not cascading from sessions logic implicitly, usually we need explicit policy)
-- Assuming messages have RLS enabled
drop policy if exists "Users can view own messages" on chat_messages;

create policy "Users and Scouts can view messages"
on chat_messages for select
using (
  auth.uid() = user_id -- Simplest check if user_id is on messages
  OR
  exists (
     select 1 from chat_sessions
     where chat_sessions.id = chat_messages.session_id
     and (
        chat_sessions.user_id = auth.uid()
        OR
        exists (
          select 1 from scout_students 
          where scout_students.scout_id = auth.uid() 
          and scout_students.student_id = chat_sessions.user_id
        )
     )
  )
);
