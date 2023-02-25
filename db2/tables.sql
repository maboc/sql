-- Name        : tables.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which tables are in the DB 
-- ---------------------------------------------------------------------
-- 2022-09-20 : MB : parametrizized (clpplus)
-- 2022-09-17 : MB : Initial Version

define tab_name=&1
define owner=&2
define tabschema=&3

@formatting
set verify on
select cast(tabschema as varchar(20)) tabschema, 
       cast(tabname as varchar(20)) tabname, 
       cast(owner as varchar(20)) owner, 
       decode(ownertype, 'S','S - System',
                         'U', 'U - A user') ownertype, 
       type, 
       status,
       card
from   syscat.tables
where  lower(owner) like lower('%&owner%')
       and lower(tabschema) like lower('%&tabschema%')
       and lower(tabname) like lower('%&tab_name%')
/

