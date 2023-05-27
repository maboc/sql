-- Name        : sessions.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which sessions are logged in to the instance
-- ---------------------------------------------------------------------
-- 2023-05-25 : MB : Initial Version


@settings

select sid, 
       serial#,
       username, 
       osuser, 
       machine,
       program, 
       module, 
       status, 
       logon_time 
from   v$session
order by logon_time
/
