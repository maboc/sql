-- Name        : dict.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which views and tables have the given name
-- ---------------------------------------------------------------------
-- 2023-05-25 : MB : Initial Version

@@settings.sql

define _obj=&1

select owner, 
       object_name,
       object_type 
from   dba_objects
where  lower(object_name) like lower('%&&_obj%')
       and object_type in ('TABLE','VIEW')
/
