-- Name        : sesev.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : On which events are the different sessions waiting
-- ---------------------------------------------------------------------
-- 2023-05-25 : MB : Initial Version

@@settings.sql

-- local formatting
set lines 250
select SID,
       seq#, 
       event, 
       p1text, 
       p1, 
       p2text,
       p2, 
       p3text,
       p3, 
       wait_class, 
       wait_time_micro, 
       state 
from   v$session_wait
where  wait_class not in ('Idle')
/
