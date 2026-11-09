-- Diamond Realty owner-only access hardening
-- Review and apply only after a verified database backup.
-- This migration does not delete business rows or change table structures.

create schema if not exists private;

create table if not exists private.owner_accounts (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table private.owner_accounts enable row level security;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;
revoke all on table private.owner_accounts from public, anon, authenticated;

create or replace function private.is_owner()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from private.owner_accounts oa
    where oa.user_id = (select auth.uid())
  );
$$;

revoke all on function private.is_owner() from public, anon;
grant execute on function private.is_owner() to authenticated;

-- Remove the previous broad authenticated-write policies.
drop policy if exists "admin write projects" on public.projects;
drop policy if exists "admin write plots" on public.plots;
drop policy if exists "admin read enquiries" on public.enquiries;
drop policy if exists "admin read site_visits" on public.site_visits;

-- Recreate public catalogue reads explicitly.
drop policy if exists "public read projects" on public.projects;
create policy "public read projects"
  on public.projects for select to anon, authenticated
  using (true);

drop policy if exists "public read plots" on public.plots;
create policy "public read plots"
  on public.plots for select to anon, authenticated
  using (true);

-- Only the configured owner may create, edit or delete projects and plots.
create policy "owner insert projects"
  on public.projects for insert to authenticated
  with check (private.is_owner());
create policy "owner update projects"
  on public.projects for update to authenticated
  using (private.is_owner()) with check (private.is_owner());
create policy "owner delete projects"
  on public.projects for delete to authenticated
  using (private.is_owner());

create policy "owner insert plots"
  on public.plots for insert to authenticated
  with check (private.is_owner());
create policy "owner update plots"
  on public.plots for update to authenticated
  using (private.is_owner()) with check (private.is_owner());
create policy "owner delete plots"
  on public.plots for delete to authenticated
  using (private.is_owner());

-- Customers may submit forms. Only the configured owner may read submitted leads.
drop policy if exists "public insert enquiries" on public.enquiries;
create policy "public insert enquiries"
  on public.enquiries for insert to anon, authenticated
  with check (true);

create policy "owner read enquiries"
  on public.enquiries for select to authenticated
  using (private.is_owner());

drop policy if exists "public insert site_visits" on public.site_visits;
create policy "public insert site_visits"
  on public.site_visits for insert to anon, authenticated
  with check (true);

create policy "owner read site_visits"
  on public.site_visits for select to authenticated
  using (private.is_owner());

create policy "owner update site_visits"
  on public.site_visits for update to authenticated
  using (private.is_owner()) with check (private.is_owner());

create policy "owner delete site_visits"
  on public.site_visits for delete to authenticated
  using (private.is_owner());

-- Cover the three foreign keys flagged by the performance advisor.
create index if not exists enquiries_plot_id_idx on public.enquiries(plot_id);
create index if not exists plots_project_id_idx on public.plots(project_id);
create index if not exists site_visits_project_id_idx on public.site_visits(project_id);
