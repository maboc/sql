-- Name        : schemata.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which schema's are defined
-- ---------------------------------------------------------------------
-- 2022-09-17 : MB : Initial Version

select cast(schemaname as varchar(20)) schemaname, 
       cast(owner as varchar(20)) owner, 
       decode(ownertype, 'S','S - System','U - User', ownertype) ownertype, 
       cast(definer as varchar(20)) definer, 
       decode(definertype, 'S','S - System','U','U - A user') definertype, 
       create_time 
from   syscat.schemata;
