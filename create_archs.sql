-- Name        : create_archs.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : creating a lot of archives
--               Handy when testing data guard
-- ---------------------------------------------------------------------
-- 2022-09-05 : MB : Initial Version

@settings.sql

declare
  n int:=100;
begin
  while n>0
  loop
    execute immediate 'alter system switch logfile';
    n:=n-1;
  end loop;
end;
/
