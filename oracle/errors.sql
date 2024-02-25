@settings
--local formatting
col text for a50
col line for 999999
select   owner, 
         name, 
         type, 
         line, 
         text 
from     dba_errors
order by owner,
         name,
         type,
         line
/
