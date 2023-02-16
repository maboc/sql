-- Name        : invalids.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which objects are invalid
-- ---------------------------------------------------------------------
-- 2023-02-16 : MB : Initial Version

@settings

select owner, count(*) from dba_objects where status!='VALID' group by owner;

select object_type, count(*) from dba_objects where status!='VALID' group by object_type;

select owner, object_name, object_type from dba_objects where status!='VALID'
/
