@settings

define _samples="&4"

-- local settings
col name for a30

select * 
from   (
         select /*+ ORDERED USE_NL(l) USE_NL(e) */ l.sid,
                l.laddr,
                l.name,
                l.gets 
         from   (
                  select 1 
                  from   dual 
                         connect by level<=&_samples
                ) e,
                (
                  select lh.sid, 
                         lh.laddr, 
                         lh.name, 
                         lh.gets
                  from   v$latchholder lh
                ) l
       ) ls,
       (
         select sid sidje,
                username,
                osuser,
                machine,
                sql_id,
                sql_child_number
         from   v$session
       ) ses
where  ls.sid=ses.sidje
/
