drop table if exists public.scores_momentum cascade;
create table public.scores_momentum (
  ticker text primary key,
  name text,
  score_grade text,
  purchases integer,
  sector text,
  core_non_core_etf text
);

drop table if exists public.scores_contrarian cascade;
create table public.scores_contrarian (
  ticker text primary key,
  name text,
  score_grade text,
  purchases integer,
  sector text,
  core_non_core_etf text
);

drop table if exists public.pulse_picks_profit_taking cascade;
create table if not exists public.pulse_picks_profit_taking (
  symbols text primary key,
  count integer
);
