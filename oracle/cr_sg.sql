create or replace type result_t is table of varchar2(250);
/

create or replace function sg_func (s1 in number, s2 in number, interval in number) 
  return result_t pipelined
is
  type integer_t is table of int index by pls_integer;
  type number_t is table of number index by pls_integer;
  memory1 number_t;
  memory2 number_t;
  memoryq number_t;
  memory_size number;
  c number;
  v1_new number;
  v2_new number;
  v1_old number;
  v2_old number;
  q_old number;
  q_new number;
  delta1 number;
  delta2 number;
  deltaq number;
  regel1 varchar2(250);
  regel2 varchar2(250);
  regelq varchar2(250);
  stat1 varchar2(50);
  stat2 varchar2(50);
  statq varchar2(100);
  high1 number;
  high2 number;
  low1 number;
  low2 number;
  highq number;
  lowq number;
  r result_t;
  block1 number; --block: size of a block in the graph
  block2 number;
  blockq number; 
  gl number;  --gl: graph lines
  gr number;

  function high (memory in number_t)
  return number
  is
    c number;
    h number;
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

  function low (memory in number_t)
  return number
  is
    c number;
    l number;
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

function initialize_memory(memory in out number_t, memory_size in number)
return number_t
is
  c number;
begin
  for c in 1..memory_size
  loop
    memory(c):=1;
  end loop;
  
  return memory;
end;

function fill_memory(memory in out number_t, value in number)
return number_t
is
  c number;
begin
  for c in 1..memory.count-1
  loop
    memory(c):=memory(c+1);
  end loop;
  memory(memory.count):=value;

  return memory;
end;

begin
  -- initialisation
  select name into stat1 from v$sysstat where statistic#=s1;
  select name into stat2 from v$sysstat where statistic#=s2;
  statq:=stat1||'/'||stat2;
  gl:=20; -- number of lines in a graph
  memory_size:=50;
 
  -- inititalize the arrays
  memory1:=initialize_memory(memory1, memory_size);
  memory2:=initialize_memory(memory2, memory_size);
  memoryq:=initialize_memory(memoryq, memory_size);
 
  loop

    -- get the latest values
    select value into v1_new from v$sysstat where statistic#=s1;
    select value into v2_new from v$sysstat where statistic#=s2;

    -- put the values in the arrays
    delta1:=v1_new-v1_old;
    memory1:=fill_memory(memory1, delta1);

    delta2:=v2_new-v2_old;
    memory2:=fill_memory(memory2, delta2);    

    if (delta2=0)
    then
      deltaq :=0;
    else
      deltaq:=round(delta1/delta2, 2);
    end if;
    memoryq:=fill_memory(memoryq, deltaq);

    -- get the highest and lowest values in the arrays
    high1:=high(memory1);
    low1:=low(memory1);

    high2:=high(memory2);
    low2:=low(memory2);

    highq:=high(memoryq);
    lowq:=low(memoryq);

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
