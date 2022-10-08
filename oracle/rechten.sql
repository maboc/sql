-- Name        : rechten.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : What permissions does a user have
-- ---------------------------------------------------------------------
-- 2022-10-07 : MB : Initial Version

@@settings.sql

define grantee=&1

prompt
prompt Table privileges
prompt
select * from dba_tab_privs where lower(grantee)=lower('&grantee');

prompt
prompt Role privileges
prompt
select * from dba_role_privs where lower(grantee)=lower('&grantee');

prompt
prompt Sys privileges
prompt
select * from dba_sys_privs where lower(grantee)=lower('&grantee');

