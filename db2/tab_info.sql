-- Name        : tab_info.sql
-- Author      : Martijn Bos
-- Input       : 1 - table_owner
--               2 - table_name
-- Description : information for a specific table
-- ---------------------------------------------------------------------
-- 2022-09-20 : MB : Initial Version


@formatting

select t.tabschema,
       t.tabname,
       t.owner,
       t.type,
       t.status,
       t.stats_time,
       t.tableid,
       tbs.tbspace,
       t.card,
       t.fpages
from   syscat.tables t,
       syscat.tablespaces tbs
where  lower(t.owner)=lower('&&1')
       and lower(t.tabname)=lower('&&2')
       and t.tbspaceid=tbs.tbspaceid;

select i.indschema,
       i.indname,
       i.owner,
       i.nleaf,
       i.nlevels,
       i.stats_time
from   syscat.indexes i
where  lower(owner)=lower('&&1')
       and lower(i.tabname)=lower('&&2');
