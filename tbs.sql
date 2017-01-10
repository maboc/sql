-- Name        : tbs.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : How much are all tablespaces filled up
-- ---------------------------------------------------------------------
-- 2017-01-10 : MB : Initial Version

@settings.sql

select files.tablespace_name,
       round(segs.bytes/(1024*1024*1024), 2) segs_GB,
       round(files.bytes/(1024*1024*1024),2) bytes_GB,
       '('||round(100*segs.bytes/files.bytes,2)||')' bytes_perc,
       round(files.maxbytes/(1024*1024*1024),2) maxbytes_GB,
       '('||round(100*segs.bytes/files.maxbytes,2)||')' maxbytes_perc 
from   (
         select   tablespace_name, 
                  sum(bytes) bytes, 
                  sum(maxbytes) maxbytes 
         from     dba_data_files 
         group by tablespace_name
       ) files,
       (
         select   tablespace_name, 
                  sum(bytes) bytes
         from     dba_segments 
         group by tablespace_name
       ) segs
where  segs.tablespace_name=files.tablespace_name
/
