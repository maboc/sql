@formatting

set serveroutput on

define SID=&1
define SLEEP=&2

declare
  cursor c1 is select ss.sid,
                      sn.name,
                      decode(bitand(sn.class,1),1,'User ')||decode(bitand(sn.class,2),2, 'Redo ')||decode(bitand(sn.class,4),4,'Enqueue ')||decode(bitand(sn.class,8), 8, 'Cache ')||decode(bitand(sn.class,16),16,'OS ')||decode(bitand(sn.class,32),32,'RAC ')||decode(bitand(sn.class,64),64,'SQL ')||decode(bitand(sn.class, 128), 128, 'Debug') class,
                      ss.value
               from   v$sesstat ss,
                      v$statname sn
               where  ss.statistic#=sn.statistic#
                      and ss.sid like '&SID';
  type stat_table_type is table of c1%rowtype;
  type total_stat_type is record(
                                  sid int,
                                  name varchar2(100),
                                  class varchar2(100),
                                  start_value int,
                                  end_value int,
                                  delta int
                                );
  type total_stat_table_type is table of total_stat_type;                                 
  total_stats_table total_stat_table_type:=total_stat_table_type();
  stats_start stat_table_type:=stat_table_type();
  stats_end stat_table_type:=stat_table_type();
  data_start c1%rowtype;
  data_end c1%rowtype;
  data_total total_stat_type;
  delta int;
  sorting_done int:=1;
 
  -- Function to get a specific statistic out of a table 
  function search_stat(haystack stat_table_type, needle c1%rowtype) return c1%rowtype
  is
    ret c1%rowtype;
  begin
    for i in haystack.first .. haystack.last
    loop
      if ((haystack(i).sid=needle.sid) AND (haystack(i).name=needle.name))
      then
        ret:=haystack(i);
      end if;
    end loop;

    return ret;
  end;

begin
  -- gather start stats
  open c1;

  loop
    fetch c1 bulk collect into stats_start;

    exit when c1%notfound;
  end loop;

  close c1;

  -- sleepy time
  dbms_lock.sleep(&SLEEP);

  -- gather end stats
  open c1;

  loop
    fetch c1 bulk collect into stats_end;

    exit when c1%notfound;
  end loop;

  close c1;

  -- process
  dbms_output.enable(10000000);
 
  -- first create one big table with start and end values 
  for i in stats_end.first .. stats_end.last
  loop
    data_end:=stats_end(i);
    if(data_end.value >0)
    then
      data_start:=search_stat(stats_start, data_end);

      -- if the delta is 0 then we don't collect it
      if(data_end.value-data_start.value!=0)
      then
        -- put it al in one big table
        total_stats_table.extend;
        -- data_total:=total_stats_table(total_stats_table.last);
        data_total:=total_stat_type();
        data_total.sid:=data_start.sid;
        data_total.name:=data_start.name;
        data_total.class:=data_start.class;
        data_total.start_value:=nvl(data_start.value,0);
        data_total.end_value:=nvl(data_end.value,0);
        data_total.delta:=data_end.value-data_start.value;
      
        total_stats_table(total_stats_table.last):=data_total; 
      end if;
    end if;
  end loop; 

  -- sort the table
  if(total_stats_table.last>0)
  then
    while (sorting_done!=0)
    loop
      sorting_done:=0;
      for i in total_stats_table.first .. (total_stats_table.last-1)
      loop
        if (total_stats_table(i).delta>total_stats_table(i+1).delta)
        then
          sorting_done:=1;
          data_total:=total_stats_table(i);
          total_stats_table(i):=total_stats_table(i+1);
          total_stats_table(i+1):=data_total;
        end if;
      end loop;
    end loop;
  end if;

  dbms_output.put(rpad('SID', 10, ' '));
  dbms_output.put(rpad('Statistic', 50, ' '));
  dbms_output.put(rpad('Class', 20, ' '));
  dbms_output.put(lpad('Begin', 15, ' '));
  dbms_output.put(lpad('End', 15, ' '));
  dbms_output.put(lpad('Delta', 10, ' '));
  dbms_output.put_line(' ');
  -- loop through this table
  if(total_stats_table.last>0)
  then
    for i in total_stats_table.first .. total_stats_table.last
    loop
      dbms_output.put(rpad(total_stats_table(i).sid, 10, ' '));
      dbms_output.put(rpad(total_stats_table(i).name, 50, ' '));
      dbms_output.put(rpad(total_stats_table(i).class, 20, ' '));
      dbms_output.put(lpad(total_stats_table(i).start_value, 15, ' '));
      dbms_output.put(lpad(total_stats_table(i).end_value, 15, ' '));
      dbms_output.put(lpad(total_stats_table(i).delta, 10, ' '));
      dbms_output.put_line(' ');
    end loop;
  end if;
end;
/
