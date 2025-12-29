-- 1) Enable RLS
alter table public.pulse_picks_daily enable row level security;
alter table public.scores_momentum enable row level security;
alter table public.scores_contrarian enable row level security;
alter table public.pulse_picks_profit_taking enable row level security;

-- 2) Allow SELECT for authenticated users only
drop policy if exists "read pulse_picks_daily" on public.pulse_picks_daily;
create policy "read pulse_picks_daily"
on public.pulse_picks_daily
for select
to authenticated
using (true);

drop policy if exists "read scores_momentum" on public.scores_momentum;
create policy "read scores_momentum"
on public.scores_momentum
for select
to authenticated
using (true);

drop policy if exists "read scores_contrarian" on public.scores_contrarian;
create policy "read scores_contrarian"
on public.scores_contrarian
for select
to authenticated
using (true);


