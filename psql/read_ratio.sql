-- https://www.crunchydata.com/blog/is-postgres-read-heavy-or-write-heavy-and-why-should-you-care
WITH
ratio_target AS (SELECT 5 AS ratio),
table_list AS (SELECT
 s.schemaname,
 s.relname AS table_name,
 -- Sum of heap and index blocks read from disk (from pg_statio_user_tables)
 si.heap_blks_read + si.idx_blks_read AS blocks_read,
 -- Sum of all write operations (tuples) (from pg_stat_user_tables)
s.n_tup_ins + s.n_tup_upd + s.n_tup_del AS write_tuples,
relpages * (s.n_tup_ins + s.n_tup_upd + s.n_tup_del ) / (case when reltuples = 0 then 1 else reltuples end) as blocks_write
FROM
 -- Join the user tables statistics view with the I/O statistics view
 pg_stat_user_tables AS s
JOIN pg_statio_user_tables AS si ON s.relid = si.relid
JOIN pg_class c ON c.oid = s.relid
WHERE
 -- Filter to only show tables that have had some form of read or write activity
(s.n_tup_ins + s.n_tup_upd + s.n_tup_del) > 0
AND
 (si.heap_blks_read + si.idx_blks_read) > 0
 )
SELECT *,
 CASE
   -- Handle case with no activity
   WHEN blocks_read = 0 and blocks_write = 0 THEN
     'No Activity'
   -- Handle write-heavy tables
   WHEN blocks_write * ratio > blocks_read THEN
     CASE
       WHEN blocks_read = 0 THEN 'Write-Only'
       ELSE
         ROUND(blocks_write :: numeric / blocks_read :: numeric, 1)::text || ':1 (Write-Heavy)'
     END
   -- Handle read-heavy tables
   WHEN blocks_read > blocks_write * ratio THEN
     CASE
       WHEN blocks_write = 0 THEN 'Read-Only'
       ELSE
         '1:' || ROUND(blocks_read::numeric / blocks_write :: numeric, 1)::text || ' (Read-Heavy)'
     END
   -- Handle balanced tables
   ELSE
     '1:1 (Balanced)'
 END AS activity_ratio
FROM table_list, ratio_target
ORDER BY
 -- Order by the most active tables first (sum of all operations)
 (blocks_read + blocks_write) DESC;
