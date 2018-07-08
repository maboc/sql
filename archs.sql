-- Name        : archs.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which archives are there
-- ---------------------------------------------------------------------
-- 2017-01-09 : MB : Initial Version

@@settings.sql

select   nvl2(name,
             substr(name, 0,10)||'...'||substr(name, length(name)-10, length(name)),
             '-') name,
         dest_id,
         sequence#,
         first_change#,
         first_time,
         round(blocks*block_size/(1024*1024)) MB,
         creator,
         registrar,
         standby_dest stby,
         archived,
         applied,
         deleted,
         status,
         completion_time 
from     v$archived_log
order by sequence#
/
