-- Run in Supabase SQL Editor (or via supabase db push) after linking the project.

-- 1) Profile column for supervisor signature object path (bucket: supervisor_signatures)
alter table public.userauth
  add column if not exists supervisor_signature_path text;

comment on column public.userauth.supervisor_signature_path is
  'Storage path inside supervisor_signatures bucket, e.g. {user_id}/signature.png';

-- 2) Storage bucket (private)
insert into storage.buckets (id, name, public)
values ('supervisor_signatures', 'supervisor_signatures', false)
on conflict (id) do nothing;

-- 3) Policies: authenticated users manage only objects under their user id folder
drop policy if exists "supervisor_signatures_insert_own" on storage.objects;
drop policy if exists "supervisor_signatures_select_own" on storage.objects;
drop policy if exists "supervisor_signatures_update_own" on storage.objects;
drop policy if exists "supervisor_signatures_delete_own" on storage.objects;

create policy "supervisor_signatures_insert_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'supervisor_signatures'
  and split_part(name, '/', 1) = auth.uid()::text
);

create policy "supervisor_signatures_select_own"
on storage.objects for select to authenticated
using (
  bucket_id = 'supervisor_signatures'
  and split_part(name, '/', 1) = auth.uid()::text
);

create policy "supervisor_signatures_update_own"
on storage.objects for update to authenticated
using (
  bucket_id = 'supervisor_signatures'
  and split_part(name, '/', 1) = auth.uid()::text
);

create policy "supervisor_signatures_delete_own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'supervisor_signatures'
  and split_part(name, '/', 1) = auth.uid()::text
);
