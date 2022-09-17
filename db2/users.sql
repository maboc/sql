-- Name        : users.sql
-- Author      : Martijn Bos
-- Input       : -
-- Description : Which users are defined
-- ---------------------------------------------------------------------
-- 2022-09-17 : MB : Initial Version

select cast(authid as varchar(20)) authid,
       decode(authidtype,
	      'G', 'G - Group',
	      'U', 'U - User',
	      'R', 'R - Role',
	      authidtype) authidtype,
       cast(grantor as varchar(20)) grantor,
       decode(grantortype,
	      'S', 'S - System',
	      'U', 'A user',
	      grantortype) grantortype,
       connectauth
from   sysibmadm.authorizationids a
        left join syscat.dbauth d
          on d.grantee = a.authid;
