-- Step 1
drop table if exists public.pulse_picks_daily cascade;

create table public.pulse_picks_daily (
  snapshot_date date not null,
  snapshot_date_text text not null,

  ticker text not null,
  name text,
  sector text,
  purchases integer,

  momentum_grade text,
  contrarian_grade text,

  profit_taking_count integer,

  refreshed_at timestamptz not null default now(),

  primary key (snapshot_date, ticker)
);

create index idx_pulse_picks_daily_snapshot_date
  on public.pulse_picks_daily (snapshot_date);

create index idx_pulse_picks_daily_snapshot_purchases
  on public.pulse_picks_daily (snapshot_date, purchases desc);
