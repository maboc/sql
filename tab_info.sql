-- Name        : tab_info.sql
-- Author      : Martijn Bos
-- Input       : Owner/schema
--               Table
-- Description : Show information about a table and it's indexes
-- ---------------------------------------------------------------------
-- 2017-01-10 : MB : Initial Version

@settings.sql

accept owner prompt 'Owner : '
accept table prompt 'Table : '

select owner,
       table_name,
       num_rows,
       avg_row_len,
       status,
       last_analyzed,
       blocks,
       empty_blocks,
       avg_space
from   all_tables 
where  lower(owner)=lower('&&owner') 
       and lower(table_name)=lower('&&table');

select   owner,
         index_name,
         index_type,
         uniqueness,
         blevel,
         leaf_blocks,
         distinct_keys,
         avg_leaf_blocks_per_key albpk,
         avg_data_blocks_per_key adbpk,
         clustering_factor cl_fac,
         status,
         num_rows,
         last_analyzed
from     all_indexes
where    lower(table_owner)=lower('&&owner')
         and lower(table_name)=lower('&&table')
order by owner,
         index_name;

select   index_owner,
         index_name,
         column_name,
         column_position,
         descend
from     all_ind_columns
where    lower(table_owner)=lower('&&owner')
         and lower(table_name)=lower('&&table') 
order by index_owner,
         index_name, 
         column_position
/
