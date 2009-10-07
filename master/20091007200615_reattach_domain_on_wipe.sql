
CREATE OR REPLACE FUNCTION webhosting.wipe_user(p_id integer)
  RETURNS SETOF character varying AS
$BODY$
from pgsql import *
from ox import pwgen
import xmlrpclib

ret=[]
QueryPlanner(plpy,SD)
q = Query("select domain, attached_domain from webhosting.domains where id = $1")
q.bind(p_id,"integer")
result = q.execute()
if result.nrows() == 0:
	Query("select logger.log_err('attemp to call webhosting.wipe_user() on non existing user')").execute()
	raise "Such site does not exist!"
	return

domain = result[0]["domain"]
att_domain = result[0]["attached_domain"]
q = Query("select config.get('webhosting_ip') as host, config.get('password_length') as length")
result = q.execute()[0]
host = result["host"]
pw_length = result["length"]
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % host)
proxy.unregister_user(p_id, domain)
proxy.unregister_mysql(p_id)
pw1 = pwgen(pw_length)
pw2 = pwgen(pw_length)
ret.append(pw1)
ret.append(pw2)
proxy.register_user(p_id, domain, pw1)
proxy.register_mysql(p_id, pw2)
plpy.notice(att_domain)
if att_domain:
	proxy.add_alias(p_id, att_domain)
	proxy.add_alias(p_id, 'www.' + att_domain)
proxy.reload_apache_config()
return ret
$BODY$
  LANGUAGE 'plpythonu' VOLATILE SECURITY DEFINER
  COST 100
  ROWS 5;
