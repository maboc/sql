-- Name        : sysevd.sql
-- Author      : Martijn Bos
-- Input       : the number of seconds between the samples
-- Description : On which events is the system waiting
--               Makes a sample, waits for n seconds and makes another sample
--               The delta between the samples is shown
-- ---------------------------------------------------------------------
-- 2023-05-26 : MB : Initial Version

set serveroutput on

define _WAIT=&1

declare
  cursor eventc is select wait_class, 
                          event, 
                          total_waits, 
                          time_waited_micro time_waited 
                   from   v$system_event
                   where  wait_class not in ('Idle');
  event_row eventc%ROWTYPE;

  type event_type is record(wait_class varchar2(50), 
                            event varchar2(64), 
                            total_waits_start number, 
                            total_waits_end number, 
                            time_waited_start number, 
                            time_waited_end number);
  event event_type;
  tmp event_type;

  type event_table_type is table of event_type;

  event_table event_table_type :=event_table_type();

  flag boolean:=TRUE;

begin
  dbms_output.enable(100000);

---------------------
-- Getting the first measurement
---------------------
  open eventc;

  loop
    fetch eventc into event_row;
    exit when eventc%NOTFOUND;

    event:=event_type(event_row.wait_class, event_row.event, event_row.total_waits, 0, event_row.time_waited, 0);
    event_table.extend();
    event_table(event_table.count):=event;
  end loop;

  close eventc;

---------------------
-- Waiting 
---------------------
  dbms_lock.sleep(&_WAIT);


---------------------
-- getting the second measurement
---------------------
  open eventc;

  loop
    fetch eventc into event_row;
    exit when eventc%NOTFOUND;

    for e in event_table.FIRST .. event_table.LAST
    loop
      if event_table(e).event=event_row.event
      then
        event_table(e).total_waits_end:=event_row.total_waits;
        event_table(e).time_waited_end:=event_row.time_waited; 
      end if;
    end loop;
    
  end loop;
  close eventc;

---------------------
-- Ordering results
---------------------

while (flag)
loop
  flag:=FALSE;
  for e in 1 .. event_table.count-1
  loop
    if ((event_table(e).time_waited_end-event_table(e).time_waited_start) > (event_table(e+1).time_waited_end-event_table(e+1).time_waited_start))
    then
      flag:=TRUE;
      tmp:=event_table(e);
      event_table(e):=event_table(e+1);
      event_table(e+1):=tmp;
    end if;
  end loop;
end loop;

---------------------
-- outputting results
---------------------
  dbms_output.put_line(rpad('.', 95,' ')||rpad('Delta (mus)',20,' ')||rpad('Delta',20,' ')||rpad('Delta',20,' '));
  dbms_output.put_line(rpad('Wait_Class',30,' ')||rpad('Event', 65,' ')||rpad('Time Waited',20,' ')||rpad('Total_waits',20,' ')||rpad('Average',20,' '));
  dbms_output.put_line(rpad('-',155,'-'));

  for e in event_table.FIRST .. event_table.LAST
  loop
    if((event_table(e).time_waited_start<>event_table(e).time_waited_end) or (event_table(e).total_waits_start<>event_table(e).total_waits_end))
    then
      dbms_output.put(rpad(event_table(e).wait_class,30,' '));
      dbms_output.put(rpad(event_table(e).event, 65, ' '));
      dbms_output.put(rpad(event_table(e).time_waited_end-event_table(e).time_waited_start,20,' '));
      dbms_output.put(rpad(event_table(e).total_waits_end-event_table(e).total_waits_start,20,' '));
      dbms_output.put(rpad(round((event_table(e).time_waited_end-event_table(e).time_waited_start)/(event_table(e).total_waits_end-event_table(e).total_waits_start),0),20,' '));
      dbms_output.new_line();
    end if;
  end loop;
end;
/
