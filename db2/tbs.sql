-- Name        : tbs.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which tablespaces are defined
-- ---------------------------------------------------------------------
-- 2022-09-17 : MB : Initial Version

select cast(tbspace as varchar(20)) tbspace,
       cast(owner as varchar(20)) owner,
       create_time,
       tbspaceid,
       decode(tbspacetype,
	      'D','D - DAtabase managed',
	      'S','S - System managed',
	      tbspacetype) tbspacetype,
       decode(datatype,
	      'A','A - all (regular)',
	      'L','L - all (large)',
	      'T','T - System temp',
	      'U','U - created/declared temp',
              datatype) datatype,
       extentsize,
       prefetchsize,
       overhead,
       bufferpoolid,
       cast(sgname as varchar(20)) sgname
from syscat.tablespaces;
