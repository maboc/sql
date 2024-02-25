set arraysize 25
set pagesize 0
set linesize 200

define v1=&1
define v2=&2
define interval=&3

select * from table(sg_func(&v1, &v2, &interval));

