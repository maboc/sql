-- Name        : sysstatd.sql
-- Author      : Martijn Bos
-- Input       : <n>    : the number of seconds to wait
--               <name> : name which the statistics to display should look like
-- Description : Displays the delta for system statistics over time
--               Only shows the statistics that changed in the interval
--               Otherwise the list get way to long
-- Usage       : @sysstatd <n> <name>
--
--               Getting the delta in statistics named %get% in a 10 second interval
--               @sysstat 10 get
--               
--               Getting the delta in statistics for ALL statistics for a 60 second interval
--               @sysstatd 60 %
-- ---------------------------------------------------------------------
-- 2023-05-26 : MB : Initial Version

@settings

define _WAIT=&1
define _STAT=&2

declare
  cursor statc is select sn.name,
                         ss.class,
                         ss.value 
                  from   v$sysstat ss, 
                         v$statname sn 
                  where ss.statistic#=sn.statistic#;

  stat_row statc%ROWTYPE;
  
  type stat_type is record(stat_name varchar2(100),
                           stat_class varchar2(100),
                           value_start number,
                           value_end number);
  stat stat_type;

  type stat_table_type is table of stat_type;
  stat_table stat_table_type:=stat_table_type();
  tmp varchar2(128);
begin 
  dbms_output.enable(100000);

-------------------------
-- Gather first set of samples
-------------------------
  open statc;
  
  loop
    fetch statc into stat_row;
    exit when statc%NOTFOUND;

    stat:=stat_type(stat_row.name, stat_row.class, stat_row.value, 0);
    stat_table.extend();
    stat_table(stat_table.count):=stat;

  end loop;

  close statc;

-------------------------
-- Wait for a certain amount of seconds
-------------------------
  dbms_lock.sleep(&_WAIT);


-------------------------
-- Gather second set of samples
-------------------------
  open statc;

  loop
    fetch statc into stat_row;
    exit when statc%NOTFOUND;
  
    for s in stat_table.FIRST .. stat_table.LAST
    loop
      if stat_table(s).stat_name=stat_row.name
      then
        stat_table(s).value_end:=stat_row.value;
      end if;
    end loop;
  end loop;

  close statc;

-------------------------
--  Display results
-------------------------
  dbms_output.put_line(rpad('Class',64,' ')||rpad('Event',64,' ')||rpad('Start',20,' ')||rpad('End',20,' ')||rpad('Delta',20, ' '));
  dbms_output.put_line(rpad('-',188,'-'));
  for s in stat_table.FIRST .. stat_table.LAST
  loop
    tmp:='';
    if(((stat_table(s).value_start!=stat_table(s).value_end)) AND (lower(stat_table(s).stat_name) like lower('%&_STAT%')))
    then
      if (bitand(stat_table(s).stat_class,1)=1)
      then
        tmp:='1 - User;';
      end if;

      if (bitand(stat_table(s).stat_class,2)=2)
      then
        tmp:=tmp||'2 - Redo;';
      end if;
      
      if (bitand(stat_table(s).stat_class,4)=4)
      then
        tmp:=tmp||'4 - Enqueue;';
      end if;
      
      if (bitand(stat_table(s).stat_class,8)=8)
      then
        tmp:=tmp||'8 - Cache;';
      end if;
      
      if (bitand(stat_table(s).stat_class,16)=16)
      then
        tmp:=tmp||'16 - OS;';
      end if;
      
      if (bitand(stat_table(s).stat_class,32)=32)
      then
        tmp:=tmp||'32 - RAC;';
      end if;

      if (bitand(stat_table(s).stat_class,64)=64)
      then
        tmp:=tmp||'64 - SQL;';
      end if;

      if (bitand(stat_table(s).stat_class,128)=128)
      then
        tmp:='128 - Debug;';
      end if;

      if (bitand(stat_table(s).stat_class,256)=256)
      then
        tmp:=tmp||'256 - Instance Level;';
      end if;

      dbms_output.put_line(
                            rpad(tmp,64,' ')||rpad(stat_table(s).stat_name,64,' ')||rpad(stat_table(s).value_start,20,' ')||rpad(stat_table(s).value_end,20,' ')||rpad(stat_table(s).value_end-stat_table(s).value_start,20,' ')
                          );
    end if;
  end loop;

end;
/
