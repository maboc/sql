-- Name        : stogroups.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which storagegroups are defined
-- ---------------------------------------------------------------------
-- 2022-09-17 : MB : Initial Version

select cast(sgname as varchar(20)) sgname,
       sgid,
       cast(owner as varchar(20)) owner,
       create_time,
       defaultsg,
       overhead,
       devicereadrate,
       writeoverhead,
       devicewriterate,
       datatag,
       cachingtier
from   syscat.stogroups;

select cast(storage_group_name as varchar(20)) storage_group_name,
       STORAGE_GROUP_ID,
       DBPARTITIONNUM,
       cast(DB_STORAGE_PATH as varchar(75)) db_storage_path,
       cast(DB_STORAGE_PATH_WITH_DPE as varchar(20)) db_storage_path_with_dpe,
       FS_ID,
       round(FS_TOTAL_SIZE/(1024*1024*1024),1) fs_total_size,
       round(FS_USED_SIZE/(1024*1024*1024),1) fs_used_size,
       round(STO_PATH_FREE_SIZE/(1024*1024*1024), 1) sto_path_free_size
from   table(admin_get_storage_paths('',-1));


