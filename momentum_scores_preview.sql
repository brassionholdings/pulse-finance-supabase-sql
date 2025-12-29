select
  tablename,
  rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in (
    'scores_momentum',
    'scores_contrarian',
    'pulse_picks_daily',
    'pulse_picks_profit_taking'
  );
