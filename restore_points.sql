-- Name        : restore_points.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which restorepoints do exist 
-- ---------------------------------------------------------------------
-- 0 : 2018-08-20 : MB : Initial Version

@settings.sql
--lokale settings

select *
from   v$restore_point
/
