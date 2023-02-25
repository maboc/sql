-- Name        : db_config.sql
-- Author      : Martijn Bos
-- Input       : parameter to show
-- Description : dislplays DB config values
-- ---------------------------------------------------------------------
-- 2022-09-24 : MB : Initial Version

define _p=&1

@formatting

prompt &_P
set verify on
select name,
       value,
       value_flags
from   sysibmadm.dbcfg
where  lower(name) like lower('%&_P%')
/
