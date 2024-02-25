@forrmatting
-- local formatting 
col name for a40
define _NAME=&1

select * from v$statname where lower(name) like lower('%&_NAME%')
/
