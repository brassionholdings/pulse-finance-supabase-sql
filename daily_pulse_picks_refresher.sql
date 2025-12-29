-- Step 2
drop function if exists public.refresh_pulse_picks_daily();

create or replace function public.refresh_pulse_picks_daily()
returns void
language plpgsql
as $$
declare
  d date := current_date;
  d_text text := to_char(d, 'MM/DD/YYYY');
begin

  /*
    Build today's "candidate" pulse picks, then only insert rows where:
      - ticker is new (no prior history), OR
      - purchases changed vs the most recent snapshot for that ticker
    Snapshot_date is always "today" for inserted/updated rows.
  */

  with current_picks as (
    select
      sm.ticker,
      sm.name,
      sm.sector,
      coalesce(sm.purchases, sc.purchases, 0) as purchases,
      sm.score_grade as momentum_grade,
      sc.score_grade as contrarian_grade,
      coalesce(pt.count, 0) + 1 as profit_taking_count
    from public.scores_momentum sm
    join public.scores_contrarian sc
      on sc.ticker = sm.ticker
    left join public.pulse_picks_profit_taking pt
      on pt.symbols = sm.ticker
    where coalesce(sm.purchases, sc.purchases, 0) > 0
      and upper(trim(sm.ticker)) <> 'SPY'
      and upper(trim(sc.ticker)) <> 'SPY'
  ),
  last_snapshot as (
    -- most recent existing row per ticker (could be today if you already ran it)
    select distinct on (p.ticker)
      p.ticker,
      p.snapshot_date,
      p.purchases
    from public.pulse_picks_daily p
    order by p.ticker, p.snapshot_date desc
  ),
  delta as (
    select
      d as snapshot_date,
      d_text as snapshot_date_text,
      c.ticker,
      c.name,
      c.sector,
      c.purchases,
      c.momentum_grade,
      c.contrarian_grade,
      c.profit_taking_count,
      now() as refreshed_at
    from current_picks c
    left join last_snapshot l
      on l.ticker = c.ticker
    where
      l.ticker is null                 -- new ticker
      or l.purchases is distinct from c.purchases  -- purchases changed since last run
  )
  insert into public.pulse_picks_daily (
    snapshot_date,
    snapshot_date_text,
    ticker,
    name,
    sector,
    purchases,
    momentum_grade,
    contrarian_grade,
    profit_taking_count,
    refreshed_at
  )
  select
    snapshot_date,
    snapshot_date_text,
    ticker,
    name,
    sector,
    purchases,
    momentum_grade,
    contrarian_grade,
    profit_taking_count,
    refreshed_at
  from delta
  on conflict (snapshot_date, ticker)
  do update set
    snapshot_date_text = excluded.snapshot_date_text,
    name = excluded.name,
    sector = excluded.sector,
    purchases = excluded.purchases,
    momentum_grade = excluded.momentum_grade,
    contrarian_grade = excluded.contrarian_grade,
    profit_taking_count = excluded.profit_taking_count,
    refreshed_at = excluded.refreshed_at
  -- extra safety: even if selected again, only update when purchases actually changed
  where public.pulse_picks_daily.purchases is distinct from excluded.purchases;

  -- HARD DELETE: remove SPY no matter what
  delete from public.pulse_picks_daily
  where upper(trim(ticker)) = 'SPY';

end;
$$;
