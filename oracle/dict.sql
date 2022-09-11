
define _obj=&1

select owner, 
       table_name,
       object_type 
from   dba_objects
where  lower(object_name) like lower('%&&_obj%')
/
