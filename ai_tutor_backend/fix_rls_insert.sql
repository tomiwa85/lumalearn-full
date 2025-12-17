-- Allow authenticated users to create their own sessions
create policy "Users can create own sessions"
on chat_sessions for insert
with check (auth.uid() = user_id);
