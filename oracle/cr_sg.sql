create or replace type result_t is table of varchar2(250);
/

create or replace function sg_func (s1 in int, s2 in int, interval in int) 
  return result_t 
  pipelined
is
  type integer_t is table of int index by pls_integer;
  type number_t is table of number index by pls_integer;
  memory1 integer_t;
  memory2 integer_t;
  memoryq number_t;
  memory_size int;
  c int;
  v1_new integer;
  v2_new integer;
  v1_old integer;
  v2_old integer;
  q_old number;
  q_new number;
  delta1 integer;
  delta2 integer;
  deltaq number;
  regel1 varchar2(250);
  regel2 varchar2(250);
  regelq varchar2(250);
  stat1 varchar2(50);
  stat2 varchar2(50);
  statq varchar2(100);
  high1 int;
  high2 int;
  low1 int;
  low2 int;
  highq number;
  lowq number;

  block1 int; --block: size of a block in the graph
  block2 int;
  blockq number; 
  gl int;  --gl: graph lines
  gr int;

  function high (memory in integer_t)
  return int
  is
    c int;
    h int;
  begin
    h:=memory(1);
    for c in 1..memory.count
    loop
      if memory(c)>h
      then
        h:=memory(c);
      end if;
    end loop;

  return h;
  end;
  function low (memory in integer_t)
  return int
  is
    c int;
    l int;
  begin
    l:=memory(1);
    for c in 1..memory.count
    loop
      if memory(c)<l
      then
        l:=memory(c);
      end if;
    end loop;

  return l;
  end;

begin
  -- initialisation
  select name into stat1 from v$sysstat where statistic#=s1;
  select name into stat2 from v$sysstat where statistic#=s2;
  statq:=stat1||'/'||stat2;
  gl:=20; -- number of lines in a graph
  memory_size:=50;
  
  -- inititalize the arrays
  for c in 1..memory_size
  loop
    memory1(c):=0;
  end loop;
 
  for c in 1..memory_size
  loop
    memory2(c):=0;
  end loop;

  for c in 1..memory_size
  loop
    memoryq(c):=0;
  end loop;

  loop

    -- get the latest values
    select value into v1_new from v$sysstat where statistic#=s1;
    select value into v2_new from v$sysstat where statistic#=s2;

    -- put the values in the arrays
    delta1:=v1_new-v1_old;
    for c in  1..memory_size-1
    loop
      memory1(c):=memory1(c+1);
    end loop;

    memory1(memory_size):=delta1;

    delta2:=v2_new-v2_old;
    for c in  1..memory_size-1
    loop
      memory2(c):=memory2(c+1);
    end loop;

    memory2(memory_size):=delta2;

    deltaq:=round(delta1/delta2, 2);

    for c in 1..memory_size-1
    loop
      memoryq(c):=memoryq(c+1);
    end loop;
    
    memoryq(memory_size):=deltaq;

    -- get the highest and lowest values in the arrays
    high1:=high(memory1);
    low1:=low(memory1);


    high2:=high(memory2);
    low2:=low(memory2);

    highq:=memoryq(memory_size);
    lowq:=memoryq(memory_size);
    for c in 1..memory_size
    loop
      if (memoryq(c)>highq)
      then
        highq:=memoryq(c);
      end if;
      
      if (memoryq(c)<lowq)
      then
        lowq:=memoryq(c);
      end if;
    end loop;

    -- lets's draw the arrays
    -- 1st array
    pipe row ('------------ '|| stat1 ||' --------------');
    pipe row ('- Low  : '||low1);
    pipe row ('- High : '||high1);
    for c in 1..memory_size
    loop
      regel1:=regel1||' '||memory1(c);
    end loop;
    
    pipe row (regel1);

    block1:=round(high1/gl,0);
    for gr in reverse 1..gl
    loop
      regel1:='';
      for c in 1..memory_size
      loop
        if (gr*block1<=memory1(c))
        then
          regel1:=regel1||'|';
        else
          regel1:=regel1||' ';
        end if;
      end loop;
      pipe row (regel1);
    end loop;

    pipe row ('-----------------------------------------------------');

    -- second array
    pipe row ('------------ '|| stat2 ||' --------------');
    pipe row ('- Low  : '||low2);
    pipe row ('- High : '||high2);
    for c in 1..memory_size
    loop
      regel2:=regel2||' '||memory2(c);
    end loop;
   
    pipe row (regel2);

    block2:=round(high2/gl,0);
    for gr in reverse 1..gl
    loop
      regel2:='';
      for c in 1..memory_size
      loop
        if (gr*block2<=memory2(c))
        then
          regel2:=regel2||'|';
        else
          regel2:=regel2||' ';
        end if;
      end loop;
      pipe row (regel2);
    end loop;

    pipe row ('-----------------------------------------------------');

    -- third array
    pipe row ('------------ '|| statq ||' --------------');
    pipe row ('- Low  : '||lowq);
    pipe row ('- High : '||highq);
    for c in 1..memory_size
    loop
      regelq:=regelq||' '||memoryq(c);
    end loop;

    pipe row (regelq);

    blockq:=round(highq/gl,3);
    for gr in reverse 1..gl
    loop
      regelq:='';
      for c in 1..memory_size
      loop
        if (gr*blockq<=memoryq(c))
        then
          regelq:=regelq||'|';
        else
          regelq:=regelq||' ';
        end if;
      end loop;
      pipe row (regelq);
    end loop;

    pipe row ('-----------------------------------------------------'); 


    -- reset values
    regel1:='';
    regel2:='';
    regelq:='';
    v1_old:=v1_new;
    v2_old:=v2_new;
    q_old:=q_new;
    dbms_session.sleep(interval);
  end loop;
end;
/
