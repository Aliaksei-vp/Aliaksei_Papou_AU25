--Task 1: Create table ‘table_to_delete’ and fill it
CREATE TABLE table_to_delete AS SELECT 'veeeeeeery_long_string' || x AS col FROM generate_series(1,(10^7)::int) x; 


--Task 2: Lookup how much space this table consumes
SELECT *, pg_size_pretty(total_bytes) AS total, 
pg_size_pretty(index_bytes) AS INDEX, 
pg_size_pretty(toast_bytes) AS toast, 
pg_size_pretty(table_bytes) AS TABLE FROM 
(SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM 
(SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME, c.reltuples AS row_estimate, pg_total_relation_size(c.oid) AS total_bytes, pg_indexes_size(c.oid) AS index_bytes, pg_total_relation_size(reltoastrelid) AS toast_bytes FROM pg_class c 
LEFT JOIN pg_namespace n 
ON n.oid = c.relnamespace 
WHERE relkind = 'r' ) a ) a 
WHERE table_name 
LIKE '%table_to_delete%';
--Table size is 575 MB.


--Task 3: DELETE operation on ‘table_to_delete’
DELETE FROM table_to_delete 
WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0; 
--DELETE 3333333; Query returned successfully in 3 secs 445 msec.
--Table size after DELETE is 575 MB.


--Perform VACUUM FULL
VACUUM FULL VERBOSE table_to_delete;
--Query returned successfully in 1 secs 525 msec.
--Table size after VACUUM is 383 MB.


--Task 4: Perform TRUNCATE 
TRUNCATE table_to_delete; 
--Query returned successfully in 101 msec.
--Table size after TRUNCATE is 8192 bytes.


--Task 5 conclusions
/*
a) Space consumption of ‘table_to_delete’ table before and after each operation;
Table size before operation is 575 MB;
Table size after DELETE is 575 MB;
Table size after VACUUM is 383 MB;
Table size after TRUNCATE is 8192 bytes.

DELETE does not immediately free up disk space. The table size remained at 575 MB
immediately after the DELETE operation, despite one-third of the rows being marked for deletion. 
Space reclamation requires an explicit, additional operation: VACUUM FULL.
VACUUM FULL is a resource-intensive solution that rewrites the entire table to reclaim space, taking 1.525 seconds in this test.

TRUNCATE immediately reclaims disk space. The table size dropped instantly from 575 MB to 8192 bytes after the TRUNCATE command.

b) Duration of each operation (DELETE, TRUNCATE)
TRUNCATE is significantly faster than DELETE. TRUNCATE executes in milliseconds (101 ms), 
while the DELETE operation takes several seconds (3.445 seconds) to process. 
This speed difference arises because TRUNCATE deallocates data pages in bulk rather than logging individual row deletions.
Summary:
TRUNCATE is beter for removing all rows from a large table for quick and immediate reclaim of disk space. It is the most efficient method for resetting a table.
DELETE is better for removing a specific subset of rows, when the ability to roll back the operation is  required , or when full transactional logging is needed. 
This approach requires subsequent VACUUM processes to manage space efficiently.
*/























