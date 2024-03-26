-- Name        : distri.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Shows the distribution of a (numeric) data
--               Somewhat like a histogram 
-- ---------------------------------------------------------------------
-- 2024-03-26  : MB : Bucket_width is now (max(column)-min(column))/number of buckets
-- 2024-03-23  : MB : Initial Version

-- Usage :
--   distri <table_name> <column_name>
--     @distri engines weight
--       Shows the distribution of the values in the weight colum of the table engine
--     @distri mechanic.engines length
--       Shows the distribution of the values in the length column of the table engines in schema mechanic



set lines 200
col graph for a25

define _TABLE=&1
define _COLUMN=&2

with engine as 
  (
         select   floor(distribution.&_COLUMN/buckets.bucket_width) bucket,                             -- number of the bucket
                  floor(distribution.&_COLUMN/buckets.bucket_width)*buckets.bucket_width min_value,     -- lower boundary for the values in this bucket
                  floor((distribution.&_COLUMN/buckets.bucket_width)+1)*buckets.bucket_width max_value, -- upper boundary for the values in this bucket
                  count(*) freq,                                                                        -- Number of items in the bucket
                  buckets.nov nov                                                                       -- total number of values
         from     (
                    select (max(&_COLUMN)-min(&_COLUMN))/20 bucket_width,                                               -- width of a bucket (for now we user 20 buckets)
                           count(&_COLUMN) nov                                                          -- number of values
                    from   distribution
                  ) buckets,
                  &_TABLE distribution
         group by floor(distribution.&_COLUMN/buckets.bucket_width),
                  floor(distribution.&_COLUMN/buckets.bucket_width)*buckets.bucket_width,
                  floor((distribution.&_COLUMN/buckets.bucket_width)+1)*buckets.bucket_width,
                  nov
  )
select   engine.bucket,
         engine.min_value,
         engine.max_value,
         engine.freq,
         round((100*engine.freq/engine.nov),0) perc,
         rpad('|',round((100*engine.freq/max_freq.max_freq)/5,0),'-') graph
from     engine,
         (
           select max(freq) max_freq
           from   engine
         ) max_freq
order by engine.bucket
/
