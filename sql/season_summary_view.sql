CREATE VIEW public.player_week_stats AS
SELECT
    s.year AS season_year,
    g.weeknumber AS week_number,
    g.gamedate AS game_date,
    gp.teamid AS team_id,
    t.teamname AS team_name,
    gp.playerid AS player_id,
    p.firstname AS first_name,
    p.lastname AS last_name,
    p.height AS height_in,
    p.weight AS weight_lb,
    array_to_string(ARRAY[
        NULLIF(btrim(tr.positionid1::text), ''),
        NULLIF(btrim(tr.positionid2::text), ''),
        NULLIF(btrim(tr.positionid3::text), '')
    ], ', ') AS "position",
    CASE
        WHEN tr.jerseynumber ~ '^\s*\d+(\.0+)?\s*$' THEN regexp_replace(tr.jerseynumber, '\.0+$', '')::integer
        ELSE NULL::integer
    END AS jersey_number,

    -- Passing
    count(*) FILTER (WHERE sa.actionname = 'Pass Complete') AS passing_completions,
    count(*) FILTER (WHERE sa.actionname = ANY (ARRAY['Pass Complete','Pass Incomplete'])) AS passing_attempts,
    count(*) FILTER (WHERE sa.actionname = 'Pass Complete' AND gp.istd = true) AS passing_tds,
    COALESCE(sum(NULLIF(gp.yards, '')::integer) FILTER (WHERE sa.actionname = 'Pass Complete'), 0)::bigint AS passing_yards,

    -- Rushing
    count(*) FILTER (WHERE sa.actionname = 'Rush') AS rush_attempts,
    COALESCE(sum(NULLIF(gp.yards, '')::integer) FILTER (WHERE sa.actionname = 'Rush'), 0)::bigint AS rushing_yards,
    count(*) FILTER (WHERE sa.actionname = 'Rush' AND gp.istd = true) AS rushing_tds,

    -- Receiving
    count(*) FILTER (WHERE sa.actionname = 'Pass Target') + count(*) FILTER (WHERE sa.actionname = 'Catch') AS targets,
    count(*) FILTER (WHERE sa.actionname = 'Catch') AS catches,
    COALESCE(sum(NULLIF(gp.yards, '')::integer) FILTER (WHERE sa.actionname = 'Catch'), 0)::bigint AS receiving_yards,
    count(*) FILTER (WHERE sa.actionname = 'Catch' AND gp.istd = true) AS receiving_tds,

    -- Defense: tackles
    count(*) FILTER (WHERE sa.actionname = ANY (ARRAY['Tackle','Sack'])) AS solo_tackles,
    count(*) FILTER (WHERE sa.actionname = ANY (ARRAY['Tackle Assist','Sack Assist'])) AS assisted_tackles,

    -- ✅ Total tackles (official style: includes sacks & sack assists)
    count(*) FILTER (WHERE sa.actionname = ANY (
        ARRAY['Tackle','Tackle Assist','Sack','Sack Assist']
    )) AS total_tackles,

    -- Sacks (weighted: half-sacks via sackweight)
    COALESCE(sum(gp.sackweight) FILTER (WHERE sa.actionname = ANY (ARRAY['Sack','Sack Assist'])), 0)::numeric(4,1) AS sacks,

    -- Tackles for Loss = TFLs + sacks (weighted)
    (
        COALESCE(count(*) FILTER (WHERE sa.actionname = ANY (ARRAY['Tackle For Loss','Tackle For Loss Assist'])), 0)
        + COALESCE(sum(gp.sackweight) FILTER (WHERE sa.actionname = ANY (ARRAY['Sack','Sack Assist'])), 0)
    )::numeric(4,1) AS tackles_for_loss,

    -- Pass defense
    count(*) FILTER (WHERE sa.actionname = 'Deflection') AS deflections,
    count(*) FILTER (WHERE sa.actionname = 'Interception') AS interceptions,
    count(*) FILTER (WHERE gp.istd = true AND gp.stattype = 'Defense') AS defensive_tds,
    count(*) FILTER (WHERE gp.issafety = true) AS safeties,

    -- Kicking
    count(*) FILTER (WHERE sa.actionname = ANY (ARRAY['Field Goal Attempt','Field Goal Made'])) AS fg_attempts,
    count(*) FILTER (WHERE sa.actionname = 'Field Goal Made') AS fg_made,
    count(*) FILTER (WHERE sa.actionname = ANY (ARRAY['PAT Attempt','PAT Made'])) AS pat_attempts,
    count(*) FILTER (WHERE sa.actionname = 'PAT Made') AS pat_made,

    -- Punting / Returns
    count(*) FILTER (WHERE sa.actionname = 'Punt') AS punts,
    COALESCE(sum(NULLIF(gp.yards, '')::integer) FILTER (WHERE sa.actionname = 'Punt'), 0)::bigint AS punt_yards,
    count(*) FILTER (WHERE sa.actionname = 'Kick Return') AS kick_returns,
    COALESCE(sum(NULLIF(gp.yards, '')::integer) FILTER (WHERE sa.actionname = 'Kick Return'), 0)::bigint AS kick_return_yards,
    count(*) FILTER (WHERE sa.actionname = 'Punt Return') AS punt_returns,
    COALESCE(sum(NULLIF(gp.yards, '')::integer) FILTER (WHERE sa.actionname = 'Punt Return'), 0)::bigint AS punt_return_yards

FROM gameplays gp
JOIN game g ON gp.gameid = g.gameid
JOIN season s ON g.seasonid = s.seasonid
JOIN stataction sa ON gp.statactionid = sa.statactionid
LEFT JOIN players p ON gp.playerid = p.playerid
LEFT JOIN team t ON gp.teamid = t.teamid
LEFT JOIN teamroster tr
  ON tr.teamid = gp.teamid
 AND tr.playerid = gp.playerid
 AND tr.seasonid = g.seasonid
 AND tr.enddate = '9999-12-31'
GROUP BY
    s.year, g.weeknumber, g.gamedate,
    gp.teamid, t.teamname,
    gp.playerid, p.firstname, p.lastname, p.height, p.weight,
    tr.positionid1, tr.positionid2, tr.positionid3, tr.jerseynumber;
