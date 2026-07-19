-- Run this in Supabase: Dashboard -> SQL Editor -> New query -> paste -> Run

create table projects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  location text not null,
  description text,
  cover_image_url text,
  created_at timestamptz default now()
);

create table plots (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  plot_no text not null,
  location text,
  size_sqft numeric,
  price numeric,
  facing text,
  status text default 'available', -- available | booked | sold
  created_at timestamptz default now()
);

create table enquiries (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text,
  phone text,
  message text,
  plot_id uuid references plots(id),
  created_at timestamptz default now()
);

create table site_visits (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text not null,
  email text,
  project_id uuid references projects(id),
  notes text,
  status text default 'pending', -- pending | confirmed | done
  created_at timestamptz default now()
);

-- Row Level Security
alter table projects enable row level security;
alter table plots enable row level security;
alter table enquiries enable row level security;
alter table site_visits enable row level security;

-- Public (customers) can READ projects & plots
create policy "public read projects" on projects for select using (true);
create policy "public read plots" on plots for select using (true);

-- Public (customers) can SUBMIT enquiries & site visits, but not read others' data
create policy "public insert enquiries" on enquiries for insert with check (true);
create policy "public insert site_visits" on site_visits for insert with check (true);

-- Only logged-in admin (you) can write/update/delete projects & plots, and read enquiries/visits
create policy "admin write projects" on projects for all using (auth.role() = 'authenticated');
create policy "admin write plots" on plots for all using (auth.role() = 'authenticated');
create policy "admin read enquiries" on enquiries for select using (auth.role() = 'authenticated');
create policy "admin read site_visits" on site_visits for select using (auth.role() = 'authenticated');

-- Enable real-time updates on plots so the public site updates instantly
alter publication supabase_realtime add table plots;
alter publication supabase_realtime add table projects;
