--
-- PostgreSQL database dump
--

-- Started on 2009-10-04 23:54:12 MSD

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 1899 (class 1262 OID 98306)
-- Name: master; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE master WITH TEMPLATE = template0 ENCODING = 'UTF8';


\connect master

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 11 (class 2615 OID 98307)
-- Name: config; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA config;


--
-- TOC entry 10 (class 2615 OID 98308)
-- Name: dns; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA dns;


--
-- TOC entry 9 (class 2615 OID 98473)
-- Name: logger; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA logger;


--
-- TOC entry 8 (class 2615 OID 98310)
-- Name: webhosting; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA webhosting;


--
-- TOC entry 12 (class 2615 OID 155651)
-- Name: webhosting_helpers; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA webhosting_helpers;


--
-- TOC entry 372 (class 2612 OID 98313)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE PROCEDURAL LANGUAGE plpgsql;


--
-- TOC entry 373 (class 2612 OID 98315)
-- Name: plpythonu; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE PROCEDURAL LANGUAGE plpythonu;


SET search_path = config, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- TOC entry 1545 (class 1259 OID 98316)
-- Dependencies: 11
-- Name: vars; Type: TABLE; Schema: config; Owner: -; Tablespace: 
--

CREATE TABLE vars (
    name character varying(32) NOT NULL,
    value text
);


SET search_path = dns, pg_catalog;

SET default_with_oids = false;

--
-- TOC entry 1546 (class 1259 OID 98322)
-- Dependencies: 1834 1835 10
-- Name: dns_records; Type: TABLE; Schema: dns; Owner: -; Tablespace: 
--

CREATE TABLE dns_records (
    zone text NOT NULL,
    host text NOT NULL,
    ttl integer NOT NULL,
    type text NOT NULL,
    mx_priority integer,
    data text NOT NULL,
    resp_person text,
    serial integer,
    refresh integer,
    retry integer,
    expire integer,
    minimum integer,
    id integer DEFAULT nextval(('dns.auto_increment'::text)::regclass) NOT NULL,
    CONSTRAINT type_check CHECK ((((((type = 'SOA'::text) OR (type = 'NS'::text)) OR (type = 'MX'::text)) OR (type = 'A'::text)) OR (type = 'CNAME'::text)))
);


--
-- TOC entry 1547 (class 1259 OID 98330)
-- Dependencies: 10
-- Name: slaves; Type: TABLE; Schema: dns; Owner: -; Tablespace: 
--

CREATE TABLE slaves (
    slave character varying(32) NOT NULL
);


--
-- TOC entry 1548 (class 1259 OID 98333)
-- Dependencies: 10
-- Name: xfr_table; Type: TABLE; Schema: dns; Owner: -; Tablespace: 
--

CREATE TABLE xfr_table (
    zone text NOT NULL,
    client text NOT NULL
);

SET search_path = webhosting, pg_catalog;

SET default_with_oids = false;

--
-- TOC entry 1563 (class 1259 OID 163842)
-- Dependencies: 1849 8
-- Name: accounts; Type: TABLE; Schema: webhosting; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    balance real DEFAULT 5.0
);


--
-- TOC entry 1562 (class 1259 OID 139267)
-- Dependencies: 8
-- Name: aliases; Type: TABLE; Schema: webhosting; Owner: -; Tablespace: 
--

CREATE TABLE aliases (
    user_id integer NOT NULL,
    alias character varying(64) NOT NULL
);


--
-- TOC entry 1554 (class 1259 OID 98366)
-- Dependencies: 1839 1840 1841 8
-- Name: domains; Type: TABLE; Schema: webhosting; Owner: -; Tablespace: 
--

CREATE TABLE domains (
    id integer NOT NULL,
    domain character varying(32),
    email character varying(32) DEFAULT 'stub@oxnull.net'::character varying NOT NULL,
    last_access timestamp with time zone DEFAULT now() NOT NULL,
    attached_domain character varying(64),
    account_id integer NOT NULL,
    CONSTRAINT wd_check_email CHECK (((email)::text ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$'::text))
);


SET search_path = config, pg_catalog;

--
-- TOC entry 49 (class 1255 OID 98365)
-- Dependencies: 11 372
-- Name: get(character varying); Type: FUNCTION; Schema: config; Owner: -
--

CREATE FUNCTION get(p_var character varying) RETURNS text
    AS $$
declare
	v_value text;
begin
	select value into v_value from config.vars where name=p_var;
	if not found then
		return null;
	end if;
	return v_value;
end;
$$
    LANGUAGE plpgsql SECURITY DEFINER;


SET search_path = webhosting, pg_catalog;

--
-- TOC entry 1559 (class 1259 OID 131074)
-- Dependencies: 1843 1844 1845 1846 8
-- Name: quotas; Type: TABLE; Schema: webhosting; Owner: -; Tablespace: 
--

CREATE TABLE quotas (
    id integer NOT NULL,
    disk_current_size bigint DEFAULT 0,
    disk_max_size bigint DEFAULT (config.get('default_disk_space'::character varying))::integer,
    mysql_current_size bigint DEFAULT 0,
    mysql_max_size bigint DEFAULT (config.get('default_mysql_space'::character varying))::integer
);


--
-- TOC entry 1560 (class 1259 OID 131098)
-- Dependencies: 8
-- Name: services; Type: TABLE; Schema: webhosting; Owner: -; Tablespace: 
--

CREATE TABLE services (
    id integer NOT NULL,
    title character varying(64),
    description character varying(100),
    cost real,
    duration interval,
    pyclass character varying(16)
);


--
-- TOC entry 1557 (class 1259 OID 98396)
-- Dependencies: 8
-- Name: auto_increment; Type: SEQUENCE; Schema: webhosting; Owner: -
--

CREATE SEQUENCE auto_increment
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 1558 (class 1259 OID 98449)
-- Dependencies: 1842 8
-- Name: spam_templates; Type: TABLE; Schema: webhosting; Owner: -; Tablespace: 
--

CREATE TABLE spam_templates (
    id integer DEFAULT nextval('auto_increment'::regclass) NOT NULL,
    title character varying(40),
    message text,
    subject character varying(128)
);


--
-- TOC entry 1561 (class 1259 OID 131103)
-- Dependencies: 1847 1848 8
-- Name: user_services; Type: TABLE; Schema: webhosting; Owner: -; Tablespace: 
--

CREATE TABLE user_services (
    user_id integer,
    service_id integer,
    quantity integer DEFAULT 1 NOT NULL,
    write_off boolean DEFAULT true,
    expiration_date timestamp with time zone
);


--
-- TOC entry 1564 (class 1259 OID 163903)
-- Dependencies: 1642 8
-- Name: view_domains; Type: VIEW; Schema: webhosting; Owner: -
--

CREATE VIEW view_domains AS
    SELECT domains.id, domains.domain, domains.email, (((to_char((((quotas.disk_current_size)::double precision / (quotas.disk_max_size)::double precision) * (100)::double precision), '90.00'::text) || '% ('::text) || to_char((((quotas.disk_max_size)::double precision / (1024)::double precision) / (1024)::double precision), '990'::text)) || 'M)'::text) AS disk, (((to_char((((quotas.mysql_current_size)::double precision / (quotas.mysql_max_size)::double precision) * (100)::double precision), '90.00'::text) || '% ('::text) || to_char((((quotas.mysql_max_size)::double precision / (1024)::double precision) / (1024)::double precision), '990'::text)) || 'M)'::text) AS mysql, to_char((now() - domains.last_access), 'dd дней hh24 часов назад'::text) AS ago FROM (domains LEFT JOIN quotas ON ((domains.id = quotas.id))) UNION SELECT (-1) AS id, (('TOTAL ('::text || to_char(count(*), '99990'::text)) || ')'::text) AS domain, '' AS email, (((to_char((((sum(quotas.disk_current_size))::double precision / (sum(quotas.disk_max_size))::double precision) * (100)::double precision), '90.00'::text) || '% ('::text) || to_char(((((sum(quotas.disk_max_size))::double precision / (1024)::double precision) / (1024)::double precision) / (1024)::double precision), '990'::text)) || 'G)'::text) AS disk, (((to_char((((sum(quotas.mysql_current_size))::double precision / (sum(quotas.mysql_max_size))::double precision) * (100)::double precision), '90.00'::text) || '% ('::text) || to_char(((((sum(quotas.mysql_max_size))::double precision / (1024)::double precision) / (1024)::double precision) / (1024)::double precision), '990'::text)) || 'G)'::text) AS mysql, (SELECT (('за сутки посетили '::text || to_char(count(*), '9990'::text)) || ' сайтов'::text) FROM domains WHERE ((now() - domains.last_access) < '1 day'::interval)) AS ago FROM (domains LEFT JOIN quotas ON ((domains.id = quotas.id))) ORDER BY 6, 1;


SET search_path = config, pg_catalog;

--
-- TOC entry 26 (class 1255 OID 98376)
-- Dependencies: 11 372
-- Name: can_run(text); Type: FUNCTION; Schema: config; Owner: -
--

CREATE FUNCTION can_run(p_name text) RETURNS boolean
    AS $$
declare
	v_count integer default 0;
begin
	select count(*) from pg_tables into v_count where tablename = 'running_triggers' limit 1;
	if v_count = 0 then
		create temporary table running_triggers(trigger_name text);
		return true;
	end if;
	select count(*) from running_triggers into v_count where trigger_name = p_name limit 1;
	if v_count = 0 then
		insert into running_triggers values(p_name);
		return true;
	else
		return false;
	end if;
end;
$$
    LANGUAGE plpgsql;


--
-- TOC entry 30 (class 1255 OID 98377)
-- Dependencies: 11 372
-- Name: get(character varying, text); Type: FUNCTION; Schema: config; Owner: -
--

CREATE FUNCTION get(p_var character varying, p_default text) RETURNS text
    AS $$
declare
	v_value text;
begin
	select value into v_value from config.vars where name=p_var;
	if not found then
		insert into config.vars(name, value) values(p_var, p_default);
		return p_default;
	end if;
	return v_value;
end;
$$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 27 (class 1255 OID 98378)
-- Dependencies: 372 11
-- Name: run_finished(text); Type: FUNCTION; Schema: config; Owner: -
--

CREATE FUNCTION run_finished(p_name text) RETURNS void
    AS $$
declare
	v_count integer default 0;
begin
	select count(*) from pg_tables into v_count where tablename = 'running_triggers' limit 1;
	if v_count > 0 then
		delete from running_triggers where trigger_name = p_name;
	end if;
end;
$$
    LANGUAGE plpgsql;


--
-- TOC entry 34 (class 1255 OID 98379)
-- Dependencies: 11 372
-- Name: set(character varying, text); Type: FUNCTION; Schema: config; Owner: -
--

CREATE FUNCTION set(p_var character varying, p_value text) RETURNS void
    AS $$
declare
	v_value text;
begin
	select value into v_value from config.vars where name=p_var;
	if not found then
		insert into config.vars(name, value) values(p_var, p_value);
	else
		update config.vars set value=p_value where name=p_var;
	end if;
	return;
end;
$$
    LANGUAGE plpgsql;


SET search_path = dns, pg_catalog;

--
-- TOC entry 28 (class 1255 OID 98380)
-- Dependencies: 10 373
-- Name: create_slave(character varying); Type: FUNCTION; Schema: dns; Owner: -
--

CREATE FUNCTION create_slave(p_slave character varying) RETURNS void
    AS $_$
from tempfile import NamedTemporaryFile
from os import system
from pgsql import *
import ox

QueryPlanner(plpy, SD)
file = NamedTemporaryFile("w+t")
q = Query("select count(*) as count from dns.slaves where slave=$1")
q.bind(p_slave,"varchar(32)")
count = q.execute()[0]["count"]
if count == 0:
	q = Query("insert into dns.slaves values($1)")
	q.bind(p_slave,"varchar(32)")
	q.execute()
else:
	file.write("D~\nZ~\nX~\nC~\n")
records = Query("select * from dns.dns_records").execute()
for i in xrange(0, records.nrows()):
	file.write("D+" + ox.dns_to_string(records[i]))
records = Query("select distinct zone from dns.dns_records").execute()
for i in xrange(0, records.nrows()):
	file.write("Z+%s\n" % records[i]["zone"][::-1])
file.flush()
ox.update_dns(file.name, p_slave)
ox.restart_dns(p_slave)
$_$
    LANGUAGE plpythonu;


--
-- TOC entry 29 (class 1255 OID 98381)
-- Dependencies: 373 10
-- Name: replicate(); Type: FUNCTION; Schema: dns; Owner: -
--

CREATE FUNCTION replicate() RETURNS trigger
    AS $_$
from tempfile import NamedTemporaryFile
from os import system
from pgsql import QueryPlanner,Query
import ox


QueryPlanner(plpy, SD)

q = Query("select count(*) as count from dns.dns_records where zone = $1")

def zone_count(zone_name):
	q.clear()
	q.bind(zone_name,"text")
	return int(q.execute()[0]["count"])

file = NamedTemporaryFile("w+t")
if TD["event"] == "INSERT":
	if TD["new"]["type"] == "SOA":
		TD["new"]["serial"] = 1
	if zone_count(TD["new"]["zone"]) == 0:
		file.write("Z+%s\n" % TD["new"]["zone"][::-1])
	file.write("D+%s\n" % ox.dns_to_string(TD["new"]))
elif TD["event"] == "UPDATE":
	if TD["new"]["zone"] != TD["old"]["zone"] and zone_count(TD["old"]["zone"]) == 1:
		file.write("Z-%s\n" % TD["old"]["zone"][::-1])
	if zone_count(TD["new"]["zone"]) == 0:
		file.write("Z+%s\n" % TD["new"]["zone"][::-1])
	file.write("D-%s\n" % ox.dns_to_string(TD["old"]))
	file.write("D+%s\n" % ox.dns_to_string(TD["new"]))
else:
	if zone_count(TD["old"]["zone"]) == 1:
		file.write("Z-%s\n" % TD["old"]["zone"][::-1])
	file.write("D-%s\n" % ox.dns_to_string(TD["old"]))
file.flush()

hosts = Query("select slave from dns.slaves").execute()
for i in range(0, hosts.nrows()):
	ox.update_dns(file.name, hosts[i]["slave"])
if TD["event"] == "INSERT" and TD["new"]["type"] == "SOA":
		return "MODIFY"
return "Ok"
$_$
    LANGUAGE plpythonu;


--
-- TOC entry 31 (class 1255 OID 98382)
-- Dependencies: 372 10
-- Name: sync_slaves(); Type: FUNCTION; Schema: dns; Owner: -
--

CREATE FUNCTION sync_slaves() RETURNS void
    AS $$
declare
	v_slave varchar(32);
begin
	for v_slave in select slave from dns.slaves loop
		perform dns.create_slave(v_slave);
	end loop;
end;
$$
    LANGUAGE plpgsql;


--
-- TOC entry 33 (class 1255 OID 98383)
-- Dependencies: 373 10
-- Name: update_serial(); Type: FUNCTION; Schema: dns; Owner: -
--

CREATE FUNCTION update_serial() RETURNS trigger
    AS $_$
from pgsql import QueryPlanner, Query
QueryPlanner(plpy, SD)
if SD.has_key("updating_serial"): return None
SD["updating_serial"] = True
update_q = Query("update dns.dns_records set serial = serial + 1 where zone = $1 and type = 'SOA'")
if TD["event"] == "DELETE":
	if TD["old"]["type"] == "SOA":
		q = Query("delete from dns.dns_records where zone = $1")
		q.bind(TD["old"]["zone"], "text")
		q.execute()
	else:
		update_q.bind(TD["old"]["zone"], "text")
		update_q.execute()
	del SD["updating_serial"]
	return None
if TD["event"] == "INSERT":
	if TD["new"]["type"] == "SOA":
		TD["new"]["serial"] = 1
		del SD["updating_serial"]
		return "MODIFY"
	update_q.bind(TD["new"]["zone"], "text")
	update_q.execute()
	del SD["updating_serial"]
	return "Ok"
if TD["event"] == "UPDATE":
	if TD["old"]["type"] == "SOA" and TD["new"]["type"] == "SOA" \
		and int(TD["new"]["serial"]) > int(TD["old"]["serial"]):
		del SD["updating_serial"]
		return None
	update_q.bind(TD["new"]["zone"], "text")
	update_q.execute()
	del SD["updating_serial"]
	return "Ok"
del SD["updating_serial"]
return None
$_$
    LANGUAGE plpythonu;


SET search_path = logger, pg_catalog;

--
-- TOC entry 42 (class 1255 OID 98475)
-- Dependencies: 373 9
-- Name: log_err(character varying); Type: FUNCTION; Schema: logger; Owner: -
--

CREATE FUNCTION log_err(p_msg character varying) RETURNS void
    AS $$
import syslog

syslog.openlog('master_db')
syslog.syslog(syslog.LOG_ERR, p_msg)
syslog.closelog()
$$
    LANGUAGE plpythonu;


--
-- TOC entry 44 (class 1255 OID 98474)
-- Dependencies: 9 373
-- Name: log_info(character varying); Type: FUNCTION; Schema: logger; Owner: -
--

CREATE FUNCTION log_info(p_msg character varying) RETURNS void
    AS $$
import syslog

syslog.openlog('master_db')
syslog.syslog(syslog.LOG_INFO, p_msg)
syslog.closelog()
$$
    LANGUAGE plpythonu;

SET search_path = webhosting, pg_catalog;

--
-- TOC entry 52 (class 1255 OID 114699)
-- Dependencies: 373 8
-- Name: attach_domain(integer, character varying); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION attach_domain(p_id integer, p_domain character varying) RETURNS void
    AS $_$
from pgsql import *
import xmlrpclib

QueryPlanner(plpy,SD)
pl_domain = p_domain.lower()
q = Query("select email, attached_domain from webhosting.domains where id = $1")
q.bind(p_id,"integer")
result = q.execute()
if result.nrows() == 0:
	Query("select logger.log_err('attemp to attach domain to non existing id')").execute()
	raise "No such id!"
	return
email = result[0]["email"]
att_domain = result[0]["attached_domain"]
if att_domain:
	raise "Can't attach second domain to id. Domain '%s' is alreade attached to id %s!" % (att_domain, p_id)
q = Query("select count(*) as number from dns.dns_records where zone = $1")
q.bind(pl_domain,"varchar(60)")
num = q.execute()[0]["number"]
if num:
	raise "Zone '%s' exists in dns.dns_records!" % pl_domain
	return
q.bind(pl_domain,"varchar[60]")
q = Query("insert into dns.dns_records(zone,host,ttl,type,data,resp_person,refresh,retry,expire,minimum) 		values($1,'@',86400,'SOA','master.oxnull.net.',regexp_replace($2,'@','.') || '.',64800,1200,1209600,60)")
q.bind(pl_domain,"character varying")
q.bind(email, "character varying")
q.execute()
q = Query("insert into dns.dns_records(zone,host,ttl,type,data) values($1,'@',86400,'NS','master.oxnull.net.')")
q.bind(pl_domain,"character varying")
q.execute()
q = Query("insert into dns.dns_records(zone,host,ttl,type,data) values($1,'@',86400,'NS','slave.oxnull.net.')")
q.bind(pl_domain,"character varying")
q.execute()
q = Query("insert into dns.dns_records(zone,host,ttl,type,data) values($1,'@',86400,'A',config.get('webhosting_ip'))")
q.bind(pl_domain,"character varying")
q.execute()
q = Query("insert into dns.dns_records(zone,host,ttl,type,data) values($1,'www',86400,'CNAME','@')")
q.bind(pl_domain,"character varying")
q.execute()
q = Query("select config.get('webhosting_ip') as host")
result = q.execute()[0]
host = result["host"]
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % host)
proxy.add_alias(p_id, pl_domain)
proxy.add_alias(p_id, 'www.' + pl_domain)
proxy.reload_apache_config()
q = Query("update webhosting.domains set attached_domain = $1 where id = $2")
q.bind(pl_domain,"character varying")
q.bind(p_id,"integer")
q.execute()
$_$
    LANGUAGE plpythonu SECURITY DEFINER;


--
-- TOC entry 45 (class 1255 OID 98470)
-- Dependencies: 8 372
-- Name: check_spam(); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION check_spam() RETURNS trigger
    AS $$
declare
	v_days integer;
begin
	v_days = config.get('dead_site_warn_days')::integer;
	if old.last_access != new.last_access and now() - new.last_access >= v_days * interval '1 day' then
		perform webhosting.spam_template(new.id, 2);
	end if;
	return new;
end;
$$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 51 (class 1255 OID 131091)
-- Dependencies: 8 372
-- Name: check_spam_quotas(); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION check_spam_quotas() RETURNS trigger
    AS $$
begin
	if old.disk_current_size < old.disk_max_size and new.disk_current_size >= new.disk_max_size then
		perform webhosting.spam_template(new.id, 3);
	end if;
	if old.mysql_current_size < old.mysql_max_size and new.mysql_current_size >= new.mysql_max_size then
		perform webhosting.spam_template(new.id, 1);
	end if;
	return new;
end;
$$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 57 (class 1255 OID 139281)
-- Dependencies: 8 373
-- Name: configure_aliases(); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION configure_aliases() RETURNS trigger
    AS $$
import xmlrpclib
from pgsql import *
QueryPlanner(plpy,SD)

q = Query("select config.get('webhosting_ip') as host")
result = q.execute()[0]
host = result["host"]
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % host)
if TD["event"] == "INSERT":
	proxy.add_alias(TD["new"]["user_id"],TD["new"]["alias"])
elif TD["event"] == "UPDATE":
	proxy.remove_alias(TD["old"]["user_id"],TD["old"]["alias"])
	proxy.add_alias(TD["new"]["user_id"],TD["new"]["alias"])
else:
	proxy.remove_alias(TD["old"]["user_id"],TD["old"]["alias"])
return "Ok"
$$
    LANGUAGE plpythonu SECURITY DEFINER;


--
-- TOC entry 58 (class 1255 OID 147470)
-- Dependencies: 373 8
-- Name: configure_services(); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION configure_services() RETURNS trigger
    AS $$
from pgsql import * 
from oxservices import * 

if TD["event"] == "INSERT":
	s = OxService(plpy, SD, TD["new"]["user_id"], TD["new"]["service_id"], TD["new"]["quantity"], TD["new"]["write_off"], TD["new"]["expiration_date"])
	s.install()
elif TD["event"] == "UPDATE":
	raise "Update is prohibited!"
else:
	s = OxService(plpy, SD, TD["old"]["user_id"], TD["old"]["service_id"], TD["old"]["quantity"], TD["old"]["write_off"], TD["old"]["expiration_date"])
	s.deinstall()
return "Ok"
$$
    LANGUAGE plpythonu SECURITY DEFINER;


--
-- TOC entry 50 (class 1255 OID 114700)
-- Dependencies: 373 8
-- Name: create_user(integer, character varying, character varying); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION create_user(p_id integer, p_domain character varying, p_email character varying) RETURNS SETOF character varying
    AS $_$
from pgsql import *
from ox import pwgen
import xmlrpclib


ret = []
QueryPlanner(plpy,SD)
pl_domain = p_domain.lower()
q = Query("select count(*) as existing from webhosting.domains where id = $1 or domain = $2")
q.bind(p_id,"integer")
q.bind(pl_domain,"varchar(32)")
result = q.execute()[0]
if int(result["existing"]) > 0:
  Query("select logger.log_err('attemp to call webhosting.create_user() on existing user or domain')").execute()
  raise "User or domain exist!"
  return ret
q = Query("select config.get('webhosting_ip') as host, config.get('password_length') as length, config.get('webhosting_dns_ttl') as ttl, config.get('webhosting_dns_cname') as cname, config.get('webhosting_dns_zone') as zone")
result = q.execute()[0]
host = result["host"]
pw_length = result["length"]
ttl = result["ttl"]
cname = result["cname"]
zone = result["zone"]
pw1 = pwgen(pw_length)
pw2 = pwgen(pw_length)
ret.append(pw1)
ret.append(pw2)
q = Query("insert into webhosting.domains(id, domain, email, account_id) values($1, $2, $3, $4)")
q.bind(p_id,"integer")
q.bind(pl_domain,"varchar(32)")
q.bind(p_email,"varchar(32)")
q.bind(p_id,"integer")
q.execute()
q = Query("insert into webhosting.quotas(id) values($1)")
q.bind(p_id,"integer")
q.execute()
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % host)
proxy.register_user(p_id, pl_domain, pw1)
proxy.register_mysql(p_id, pw2)
proxy.reload_apache_config()
q = Query("insert into dns.dns_records(zone, host,ttl,type,data) values($1,$2,$3,'CNAME',$4)")
q.bind(zone,"varchar(32)")
q.bind(pl_domain,"varchar(32)")
q.bind(ttl,"integer")
q.bind(cname,"varchar(5)")
q.execute()
q = Query("select webhosting.spam_template($1,4)")
q.bind(p_id,"integer")
q.execute()
return ret
$_$
    LANGUAGE plpythonu SECURITY DEFINER ROWS 5;


--
-- TOC entry 61 (class 1255 OID 163865)
-- Dependencies: 8 372
-- Name: daily_write_off(); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION daily_write_off() RETURNS void
    AS $$
declare
	v_id integer;
	v_user_service webhosting.user_services%rowtype;
	v_amount real;
	v_balance real;
	v_cost real;
	v_account_id integer;
begin
	perform logger.log_info('daily services writing off...');
	lock webhosting.user_services in exclusive mode;
	for v_id in select id from webhosting.domains order by id loop
		for v_user_service in select * from webhosting.user_services where user_id = v_id loop
			if v_user_service.write_off then
				select cost from webhosting.services where id = v_user_service.service_id into v_cost;
				select account_id from webhosting.domains where id = v_user_service.user_id into v_account_id;
				select balance from webhosting.accounts where id = v_account_id into v_balance;
				v_amount = v_cost / 30 * v_user_service.quantity;
				if v_balance < v_amount then
					perform logger.log_info('disabled service # ' || v_user_service.service_id || ' for user # ' || v_user_service.user_id || ' - not enough money');
					delete from webhosting.user_services where user_id = v_user_service.user_id and service_id = v_user_service.service_id;
				else
					perform logger.log_info('writing off ' || v_amount || 'oxes: service # ' || v_user_service.service_id || ' for user # ' || v_user_service.user_id);
					update webhosting.accounts set balance = balance - v_amount where id = v_account_id;
				end if;
			end if;
		end loop;
	end loop;
	perform logger.log_info('finished');
end;
$$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 53 (class 1255 OID 114701)
-- Dependencies: 8 373
-- Name: detach_domain(integer); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION detach_domain(p_id integer) RETURNS void
    AS $_$
from pgsql import *
from ox import pwgen
import xmlrpclib

QueryPlanner(plpy,SD)
q = Query("select attached_domain from webhosting.domains where id = $1")
q.bind(p_id,"integer")
result = q.execute()
if result.nrows() == 0:
	Query("select logger.log_err('attemp to detach domain to non existing id')").execute()
	raise "No such id!"
att_domain = result[0]["attached_domain"]
if not att_domain:
	Query("select logger.log_err('attemp to detach non attached domain')").execute()
	raise "No domain attached!"
q = Query("delete from dns.dns_records where zone = $1")
q.bind(att_domain,"character varying")
q.execute()
q = Query("select config.get('webhosting_ip') as host")
result = q.execute()[0]
host = result["host"]
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % host)
proxy.remove_alias(p_id, att_domain)
proxy.remove_alias(p_id, 'www.' + att_domain)
proxy.reload_apache_config()
q = Query("update webhosting.domains set attached_domain = NULL where id = $1")
q.bind(p_id,"integer")
q.execute()
$_$
    LANGUAGE plpythonu SECURITY DEFINER;


--
-- TOC entry 46 (class 1255 OID 98463)
-- Dependencies: 8 373
-- Name: install_soft(integer, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION install_soft(p_id integer, p_domain character varying, p_password character varying, p_soft character varying, p_folder character varying) RETURNS void
    AS $$
from pgsql import *
import xmlrpclib

QueryPlanner(plpy,SD)

q = Query("select config.get('webhosting_ip') as host")
result = q.execute()[0]
host = result["host"]
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % host)
proxy.install_soft(p_id, p_domain, p_password, p_soft, p_folder)
$$
    LANGUAGE plpythonu SECURITY DEFINER;


--
-- TOC entry 54 (class 1255 OID 139286)
-- Dependencies: 8 372
-- Name: link_id(integer, integer, character varying); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION link_id(p_main_id integer, p_sub_id integer, p_subdomain character varying) RETURNS void
    AS $$
declare
	v_att_domain varchar(64);
begin
	select attached_domain from webhosting.domains into v_att_domain where id=p_main_id;
	if not found then
		raise exception 'No attached domain at main id %!', id;
	end if;
	insert into webhosting.aliases values(p_sub_id, p_subdomain || '.' || v_att_domain);
	insert into dns.dns_records(zone,host,ttl,type,data)
		values(v_att_domain, p_subdomain, config.get('webhosting_dns_ttl')::integer, 'CNAME', 'webhosting');
	update webhosting.domains set attached_domain=p_subdomain || '.' || v_att_domain where id=p_sub_id;
end;
$$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 48 (class 1255 OID 114696)
-- Dependencies: 8 373
-- Name: pause_processing(boolean); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION pause_processing(p_pause boolean) RETURNS void
    AS $$
from pgsql import *
import xmlrpclib

QueryPlanner(plpy,SD)

q = Query("select config.get('main_ip') as host")
result = q.execute()[0]
host = result["host"]
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % host)
proxy.pause_processing(p_pause)
$$
    LANGUAGE plpythonu SECURITY DEFINER;


--
-- TOC entry 56 (class 1255 OID 139266)
-- Dependencies: 8 373
-- Name: recreate_apache_configs(); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION recreate_apache_configs() RETURNS void
    AS $$
from pgsql import *
import xmlrpclib

QueryPlanner(plpy,SD)

q = Query("select config.get('webhosting_ip') as host")
result = q.execute()[0]
host = result["host"]
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % host)
q = Query("select id, domain from webhosting.domains")
for result in q.execute():
	proxy.create_apache_config(result["id"], result["domain"])
q = Query("select * from webhosting.aliases")
result = q.execute()
for x in xrange(0,result.nrows()):
	 proxy.add_alias(result[x]["user_id"],result[x]["alias"])
proxy.reload_apache_config()
$$
    LANGUAGE plpythonu SECURITY DEFINER;


--
-- TOC entry 59 (class 1255 OID 98390)
-- Dependencies: 373 8
-- Name: remove_user(integer); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION remove_user(p_id integer) RETURNS void
    AS $_$
import xmlrpclib
from pgsql import *

QueryPlanner(plpy,SD)
q = Query("select domain from webhosting.domains where id = $1 for update")
q.bind(p_id,"integer")
result = q.execute()
if result.nrows() == 0:
	Query("select logger.log_err('attemp to call webhosting.remove_user() on non existing user')").execute()
	raise "Such site does not exist!"
	return
pl_domain = result[0]["domain"]
q = Query("select config.get('webhosting_ip') as host, config.get('main_ip') as main")
result = q.execute()[0]
host = result["host"]
main = result["main"]
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % host)
proxy.unregister_user(p_id, pl_domain)
proxy.unregister_mysql(p_id)
proxy.reload_apache_config()
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % main)
proxy.set_status(p_id,'removed')
q = Query("delete from webhosting.quotas where id=$1")
q.bind(p_id,"integer")
q.execute()
q = Query("delete from webhosting.domains where id=$1")
q.bind(p_id,"integer")
q.execute()
q = Query("select config.get('webhosting_dns_zone') as zone")
result = q.execute()[0]
zone = result["zone"]
q = Query("delete from dns.dns_records where zone=$1 and host=$2 and type='CNAME'")
q.bind(zone,"varchar(32)")
q.bind(pl_domain,"varchar(32)")
q.execute()
$_$
    LANGUAGE plpythonu SECURITY DEFINER;


--
-- TOC entry 47 (class 1255 OID 98467)
-- Dependencies: 372 8
-- Name: spam_template(integer, integer); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION spam_template(p_user_id integer, p_template_id integer) RETURNS void
    AS $$
declare
	v_subject webhosting.spam_templates.subject%type;
	v_message webhosting.spam_templates.message%type;
begin
	select subject, message into v_subject, v_message from webhosting.spam_templates where id = p_template_id;	
	perform webhosting.spam_user(p_user_id, v_subject, v_message);
end;
$$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 43 (class 1255 OID 98468)
-- Dependencies: 372 8
-- Name: spam_template_all(integer); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION spam_template_all(p_template_id integer) RETURNS void
    AS $$
declare
	v_subject webhosting.spam_templates.subject%type;
	v_message webhosting.spam_templates.message%type;
	v_id integer;
begin
	select subject, message into v_subject, v_message from webhosting.spam_templates where id = p_template_id;	
	for v_id in select id from webhosting.domains loop 
		perform webhosting.spam_user(v_id, v_subject, v_message);
	end loop;
end;
$$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 41 (class 1255 OID 98459)
-- Dependencies: 373 8
-- Name: spam_user(integer, character varying, text); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION spam_user(p_id integer, p_subject character varying, p_content text) RETURNS void
    AS $_$
from ox import *
from pgsql import *

ret = []
QueryPlanner(plpy,SD)

q = Query("select count(*) as existing from webhosting.domains where id = $1")
q.bind(p_id,"integer")
result = q.execute()[0]
if int(result["existing"]) == 0:
	raise "User does not exist!"
	return
q = Query("select config.get('spam_from') as spam_from")
result = q.execute()[0]
spam_from = result["spam_from"]
q = Query("select email from webhosting.domains where id=$1")
q.bind(p_id,"integer")
result = q.execute()[0]
send_to = result["email"]
#sendmail(spam_from, p_subject, send_to, p_content)
$_$
    LANGUAGE plpythonu SECURITY DEFINER;


--
-- TOC entry 32 (class 1255 OID 98391)
-- Dependencies: 8 373
-- Name: update_pkg(); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION update_pkg() RETURNS void
    AS $$
import xmlrpclib
from pgsql import *

ret = []
QueryPlanner(plpy,SD)
q = Query("select config.get('webhosting_ip') as host")
result = q.execute()[0]
host = result["host"]
proxy = xmlrpclib.ServerProxy("http://%s:1979/" % host)
proxy.update_pkg()
$$
    LANGUAGE plpythonu SECURITY DEFINER;


--
-- TOC entry 40 (class 1255 OID 98464)
-- Dependencies: 372 8
-- Name: wipe_dead_sites(); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION wipe_dead_sites() RETURNS void
    AS $$
declare
	v_id integer;
	--v_days integer;
	v_balance real;
	v_services integer;
begin
	--v_days = config.get('dead_site_days')::integer;
	perform logger.log_info('wiping dead sites...');
	for v_id in select id from webhosting.domains where now() - last_access > interval '1 day' order by id loop
		select count(*) from webhosting.user_services where user_id = v_id into v_services;
		if v_services = 0 then
			select balance from webhosting.accounts where id = v_id into v_balance;
			if v_balance < 1.0 then
				perform webhosting.remove_user(v_id);
			else
				update webhosting.accounts set balance = balance - 1 where id = v_id;
				perform webhosting.spam_template(v_id, 5);
			end if;
		end if;
	end loop;
	perform logger.log_info('finished');
end;
$$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 60 (class 1255 OID 163866)
-- Dependencies: 373 8
-- Name: wipe_user(integer); Type: FUNCTION; Schema: webhosting; Owner: -
--

CREATE FUNCTION wipe_user(p_id integer) RETURNS SETOF character varying
    AS $_$
from pgsql import *
from ox import pwgen
import xmlrpclib

ret=[]
QueryPlanner(plpy,SD)
q = Query("select domain from webhosting.domains where id = $1")
q.bind(p_id,"integer")
result = q.execute()
if result.nrows() == 0:
	Query("select logger.log_err('attemp to call webhosting.wipe_user() on non existing user')").execute()
	raise "Such site does not exist!"
	return

domain = result[0]["domain"]
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
proxy.reload_apache_config()
return ret
$_$
    LANGUAGE plpythonu SECURITY DEFINER ROWS 5;


SET search_path = webhosting_helpers, pg_catalog;

--
-- TOC entry 55 (class 1255 OID 155654)
-- Dependencies: 372 12
-- Name: seconds_to_midnight(); Type: FUNCTION; Schema: webhosting_helpers; Owner: -
--

CREATE FUNCTION seconds_to_midnight() RETURNS integer
    AS $$
declare
	v_hours integer;
	v_minutes integer;
	v_seconds integer;
	v_interval interval;
begin
	select date_trunc('day', now() + interval '1 day') - now() into v_interval;
	select extract('hours' from v_interval) into v_hours;
	select extract('minutes' from v_interval) into v_minutes;
	select extract('seconds' from v_interval)::integer into v_seconds;
	v_seconds = v_seconds + v_minutes * 60 + v_hours * 60 * 60;
	return v_seconds;
end;
$$
    LANGUAGE plpgsql;


SET search_path = dns, pg_catalog;

--
-- TOC entry 1555 (class 1259 OID 98392)
-- Dependencies: 10
-- Name: auto_increment; Type: SEQUENCE; Schema: dns; Owner: -
--

CREATE SEQUENCE auto_increment
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

SET search_path = config, pg_catalog;

--
-- TOC entry 1851 (class 2606 OID 98413)
-- Dependencies: 1545 1545
-- Name: vars_pkey; Type: CONSTRAINT; Schema: config; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vars
    ADD CONSTRAINT vars_pkey PRIMARY KEY (name);


SET search_path = dns, pg_catalog;

--
-- TOC entry 1854 (class 2606 OID 98415)
-- Dependencies: 1546 1546
-- Name: primary_id; Type: CONSTRAINT; Schema: dns; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dns_records
    ADD CONSTRAINT primary_id PRIMARY KEY (id);


--
-- TOC entry 1858 (class 2606 OID 98417)
-- Dependencies: 1547 1547
-- Name: slaves_pkey; Type: CONSTRAINT; Schema: dns; Owner: -; Tablespace: 
--

ALTER TABLE ONLY slaves
    ADD CONSTRAINT slaves_pkey PRIMARY KEY (slave);


--
-- TOC entry 1860 (class 2606 OID 98419)
-- Dependencies: 1548 1548 1548
-- Name: zone_client_index; Type: CONSTRAINT; Schema: dns; Owner: -; Tablespace: 
--

ALTER TABLE ONLY xfr_table
    ADD CONSTRAINT zone_client_index PRIMARY KEY (zone, client);


SET search_path = webhosting, pg_catalog;

--
-- TOC entry 1883 (class 2606 OID 163847)
-- Dependencies: 1563 1563
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: webhosting; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 1878 (class 2606 OID 131082)
-- Dependencies: 1559 1559
-- Name: quotas_pkey; Type: CONSTRAINT; Schema: webhosting; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quotas
    ADD CONSTRAINT quotas_pkey PRIMARY KEY (id);


--
-- TOC entry 1880 (class 2606 OID 131102)
-- Dependencies: 1560 1560
-- Name: services_pkey; Type: CONSTRAINT; Schema: webhosting; Owner: -; Tablespace: 
--

ALTER TABLE ONLY services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- TOC entry 1876 (class 2606 OID 98457)
-- Dependencies: 1558 1558
-- Name: spam_templates_pkey; Type: CONSTRAINT; Schema: webhosting; Owner: -; Tablespace: 
--

ALTER TABLE ONLY spam_templates
    ADD CONSTRAINT spam_templates_pkey PRIMARY KEY (id);


--
-- TOC entry 1872 (class 2606 OID 98431)
-- Dependencies: 1554 1554
-- Name: wd_pk_id; Type: CONSTRAINT; Schema: webhosting; Owner: -; Tablespace: 
--

ALTER TABLE ONLY domains
    ADD CONSTRAINT wd_pk_id PRIMARY KEY (id);


--
-- TOC entry 1874 (class 2606 OID 98433)
-- Dependencies: 1554 1554 1554
-- Name: wd_uq_id_dm; Type: CONSTRAINT; Schema: webhosting; Owner: -; Tablespace: 
--

ALTER TABLE ONLY domains
    ADD CONSTRAINT wd_uq_id_dm UNIQUE (id, domain);


SET search_path = dns, pg_catalog;

--
-- TOC entry 1852 (class 1259 OID 98434)
-- Dependencies: 1546
-- Name: host_index; Type: INDEX; Schema: dns; Owner: -; Tablespace: 
--

CREATE INDEX host_index ON dns_records USING btree (host);


--
-- TOC entry 1855 (class 1259 OID 98435)
-- Dependencies: 1546
-- Name: type_index; Type: INDEX; Schema: dns; Owner: -; Tablespace: 
--

CREATE INDEX type_index ON dns_records USING btree (type);


--
-- TOC entry 1856 (class 1259 OID 98436)
-- Dependencies: 1546
-- Name: zone_index; Type: INDEX; Schema: dns; Owner: -; Tablespace: 
--

CREATE INDEX zone_index ON dns_records USING btree (zone);


SET search_path = webhosting, pg_catalog;

--
-- TOC entry 1881 (class 1259 OID 139283)
-- Dependencies: 1562
-- Name: wha_id_idx; Type: INDEX; Schema: webhosting; Owner: -; Tablespace: 
--

CREATE INDEX wha_id_idx ON aliases USING btree (user_id);


SET search_path = dns, pg_catalog;

--
-- TOC entry 1891 (class 2620 OID 98437)
-- Dependencies: 1546 29
-- Name: replication_trigger; Type: TRIGGER; Schema: dns; Owner: -
--

CREATE TRIGGER replication_trigger
    BEFORE INSERT OR DELETE OR UPDATE ON dns_records
    FOR EACH ROW
    EXECUTE PROCEDURE replicate();


--
-- TOC entry 1892 (class 2620 OID 98438)
-- Dependencies: 1546 33
-- Name: serial_trigger; Type: TRIGGER; Schema: dns; Owner: -
--

CREATE TRIGGER serial_trigger
    AFTER INSERT OR DELETE OR UPDATE ON dns_records
    FOR EACH ROW
    EXECUTE PROCEDURE update_serial();


SET search_path = webhosting, pg_catalog;

--
-- TOC entry 1893 (class 2620 OID 98472)
-- Dependencies: 45 1554
-- Name: check_spam; Type: TRIGGER; Schema: webhosting; Owner: -
--

CREATE TRIGGER check_spam
    AFTER UPDATE ON domains
    FOR EACH ROW
    EXECUTE PROCEDURE check_spam();


--
-- TOC entry 1894 (class 2620 OID 131092)
-- Dependencies: 51 1559
-- Name: quotas_spam_trigger; Type: TRIGGER; Schema: webhosting; Owner: -
--

CREATE TRIGGER quotas_spam_trigger
    AFTER UPDATE ON quotas
    FOR EACH ROW
    EXECUTE PROCEDURE check_spam_quotas();


--
-- TOC entry 1896 (class 2620 OID 139282)
-- Dependencies: 1562 57
-- Name: wha_trigger; Type: TRIGGER; Schema: webhosting; Owner: -
--

CREATE TRIGGER wha_trigger
    AFTER INSERT OR DELETE OR UPDATE ON aliases
    FOR EACH ROW
    EXECUTE PROCEDURE configure_aliases();


--
-- TOC entry 1895 (class 2620 OID 147471)
-- Dependencies: 58 1561
-- Name: whus_services; Type: TRIGGER; Schema: webhosting; Owner: -
--

CREATE TRIGGER whus_services
    BEFORE INSERT OR DELETE OR UPDATE ON user_services
    FOR EACH ROW
    EXECUTE PROCEDURE configure_services();

SET search_path = webhosting, pg_catalog;

--
-- TOC entry 1886 (class 2606 OID 163853)
-- Dependencies: 1554 1882 1563
-- Name: wd_account_fkey; Type: FK CONSTRAINT; Schema: webhosting; Owner: -
--

ALTER TABLE ONLY domains
    ADD CONSTRAINT wd_account_fkey FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- TOC entry 1888 (class 2606 OID 131108)
-- Dependencies: 1561 1554 1871
-- Name: wd_id; Type: FK CONSTRAINT; Schema: webhosting; Owner: -
--

ALTER TABLE ONLY user_services
    ADD CONSTRAINT wd_id FOREIGN KEY (user_id) REFERENCES domains(id);


--
-- TOC entry 1890 (class 2606 OID 139272)
-- Dependencies: 1871 1554 1562
-- Name: whd_id; Type: FK CONSTRAINT; Schema: webhosting; Owner: -
--

ALTER TABLE ONLY aliases
    ADD CONSTRAINT whd_id FOREIGN KEY (user_id) REFERENCES domains(id) ON DELETE CASCADE;


--
-- TOC entry 1887 (class 2606 OID 163858)
-- Dependencies: 1871 1559 1554
-- Name: wq_domain_fkey; Type: FK CONSTRAINT; Schema: webhosting; Owner: -
--

ALTER TABLE ONLY quotas
    ADD CONSTRAINT wq_domain_fkey FOREIGN KEY (id) REFERENCES domains(id);


--
-- TOC entry 1889 (class 2606 OID 131113)
-- Dependencies: 1560 1879 1561
-- Name: ws_id; Type: FK CONSTRAINT; Schema: webhosting; Owner: -
--

ALTER TABLE ONLY user_services
    ADD CONSTRAINT ws_id FOREIGN KEY (service_id) REFERENCES services(id);


--
-- TOC entry 1900 (class 0 OID 0)
-- Dependencies: 11
-- Name: config; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA config FROM PUBLIC;
REVOKE ALL ON SCHEMA config FROM master;
GRANT ALL ON SCHEMA config TO master;
GRANT USAGE ON SCHEMA config TO webhosting;


--
-- TOC entry 1901 (class 0 OID 0)
-- Dependencies: 10
-- Name: dns; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA dns FROM PUBLIC;
REVOKE ALL ON SCHEMA dns FROM master;
GRANT ALL ON SCHEMA dns TO master;


--
-- TOC entry 1902 (class 0 OID 0)
-- Dependencies: 9
-- Name: logger; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA logger FROM PUBLIC;
REVOKE ALL ON SCHEMA logger FROM master;
GRANT ALL ON SCHEMA logger TO master;

--
-- TOC entry 1905 (class 0 OID 0)
-- Dependencies: 3
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 1906 (class 0 OID 0)
-- Dependencies: 8
-- Name: webhosting; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA webhosting FROM PUBLIC;
REVOKE ALL ON SCHEMA webhosting FROM master;
GRANT ALL ON SCHEMA webhosting TO master;
GRANT USAGE ON SCHEMA webhosting TO webhosting;
GRANT USAGE ON SCHEMA webhosting TO main;


SET search_path = config, pg_catalog;

--
-- TOC entry 1907 (class 0 OID 0)
-- Dependencies: 1545
-- Name: vars; Type: ACL; Schema: config; Owner: -
--

REVOKE ALL ON TABLE vars FROM PUBLIC;
REVOKE ALL ON TABLE vars FROM master;
GRANT ALL ON TABLE vars TO master;
GRANT SELECT ON TABLE vars TO main;
GRANT SELECT ON TABLE vars TO webhosting;


SET search_path = dns, pg_catalog;

--
-- TOC entry 1908 (class 0 OID 0)
-- Dependencies: 1546
-- Name: dns_records; Type: ACL; Schema: dns; Owner: -
--

REVOKE ALL ON TABLE dns_records FROM PUBLIC;
REVOKE ALL ON TABLE dns_records FROM master;
GRANT ALL ON TABLE dns_records TO master;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE dns_records TO main;


--
-- TOC entry 1909 (class 0 OID 0)
-- Dependencies: 1547
-- Name: slaves; Type: ACL; Schema: dns; Owner: -
--

REVOKE ALL ON TABLE slaves FROM PUBLIC;
REVOKE ALL ON TABLE slaves FROM master;
GRANT ALL ON TABLE slaves TO master;
GRANT SELECT ON TABLE slaves TO main;


SET search_path = webhosting, pg_catalog;

--
-- TOC entry 1915 (class 0 OID 0)
-- Dependencies: 1563
-- Name: accounts; Type: ACL; Schema: webhosting; Owner: -
--

REVOKE ALL ON TABLE accounts FROM PUBLIC;
REVOKE ALL ON TABLE accounts FROM master;
GRANT ALL ON TABLE accounts TO master;
GRANT SELECT,INSERT,UPDATE ON TABLE accounts TO main;


--
-- TOC entry 1916 (class 0 OID 0)
-- Dependencies: 1554
-- Name: domains; Type: ACL; Schema: webhosting; Owner: -
--

REVOKE ALL ON TABLE domains FROM PUBLIC;
REVOKE ALL ON TABLE domains FROM master;
GRANT ALL ON TABLE domains TO master;
GRANT SELECT,INSERT,DELETE ON TABLE domains TO main;
GRANT SELECT,UPDATE ON TABLE domains TO webhosting;


SET search_path = config, pg_catalog;

--
-- TOC entry 1917 (class 0 OID 0)
-- Dependencies: 49
-- Name: get(character varying); Type: ACL; Schema: config; Owner: -
--

REVOKE ALL ON FUNCTION get(p_var character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION get(p_var character varying) FROM master;
GRANT ALL ON FUNCTION get(p_var character varying) TO master;
GRANT ALL ON FUNCTION get(p_var character varying) TO PUBLIC;
GRANT ALL ON FUNCTION get(p_var character varying) TO main;


SET search_path = webhosting, pg_catalog;

--
-- TOC entry 1918 (class 0 OID 0)
-- Dependencies: 1559
-- Name: quotas; Type: ACL; Schema: webhosting; Owner: -
--

REVOKE ALL ON TABLE quotas FROM PUBLIC;
REVOKE ALL ON TABLE quotas FROM master;
GRANT ALL ON TABLE quotas TO master;
GRANT SELECT,UPDATE ON TABLE quotas TO webhosting;
GRANT SELECT,UPDATE ON TABLE quotas TO main;


--
-- TOC entry 1919 (class 0 OID 0)
-- Dependencies: 1560
-- Name: services; Type: ACL; Schema: webhosting; Owner: -
--

REVOKE ALL ON TABLE services FROM PUBLIC;
REVOKE ALL ON TABLE services FROM master;
GRANT ALL ON TABLE services TO master;
GRANT SELECT ON TABLE services TO main;


--
-- TOC entry 1920 (class 0 OID 0)
-- Dependencies: 1558
-- Name: spam_templates; Type: ACL; Schema: webhosting; Owner: -
--

REVOKE ALL ON TABLE spam_templates FROM PUBLIC;
REVOKE ALL ON TABLE spam_templates FROM postgres;
GRANT ALL ON TABLE spam_templates TO postgres;
GRANT SELECT ON TABLE spam_templates TO webhosting;
GRANT SELECT ON TABLE spam_templates TO main;


--
-- TOC entry 1921 (class 0 OID 0)
-- Dependencies: 1561
-- Name: user_services; Type: ACL; Schema: webhosting; Owner: -
--

REVOKE ALL ON TABLE user_services FROM PUBLIC;
REVOKE ALL ON TABLE user_services FROM master;
GRANT ALL ON TABLE user_services TO master;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE user_services TO main;


SET search_path = logger, pg_catalog;

--
-- TOC entry 1922 (class 0 OID 0)
-- Dependencies: 42
-- Name: log_err(character varying); Type: ACL; Schema: logger; Owner: -
--

REVOKE ALL ON FUNCTION log_err(p_msg character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION log_err(p_msg character varying) FROM postgres;
GRANT ALL ON FUNCTION log_err(p_msg character varying) TO postgres;
GRANT ALL ON FUNCTION log_err(p_msg character varying) TO PUBLIC;
GRANT ALL ON FUNCTION log_err(p_msg character varying) TO main;


--
-- TOC entry 1923 (class 0 OID 0)
-- Dependencies: 44
-- Name: log_info(character varying); Type: ACL; Schema: logger; Owner: -
--

REVOKE ALL ON FUNCTION log_info(p_msg character varying) FROM PUBLIC;
REVOKE ALL ON FUNCTION log_info(p_msg character varying) FROM postgres;
GRANT ALL ON FUNCTION log_info(p_msg character varying) TO postgres;
GRANT ALL ON FUNCTION log_info(p_msg character varying) TO PUBLIC;
GRANT ALL ON FUNCTION log_info(p_msg character varying) TO main;


SET search_path = webhosting, pg_catalog;

--
-- TOC entry 1924 (class 0 OID 0)
-- Dependencies: 45
-- Name: check_spam(); Type: ACL; Schema: webhosting; Owner: -
--

REVOKE ALL ON FUNCTION check_spam() FROM PUBLIC;
REVOKE ALL ON FUNCTION check_spam() FROM postgres;
GRANT ALL ON FUNCTION check_spam() TO postgres;
GRANT ALL ON FUNCTION check_spam() TO webhosting;


--
-- TOC entry 1925 (class 0 OID 0)
-- Dependencies: 59
-- Name: remove_user(integer); Type: ACL; Schema: webhosting; Owner: -
--

REVOKE ALL ON FUNCTION remove_user(p_id integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION remove_user(p_id integer) FROM postgres;
GRANT ALL ON FUNCTION remove_user(p_id integer) TO postgres;
GRANT ALL ON FUNCTION remove_user(p_id integer) TO PUBLIC;
GRANT ALL ON FUNCTION remove_user(p_id integer) TO master;
GRANT ALL ON FUNCTION remove_user(p_id integer) TO main;


SET search_path = dns, pg_catalog;

--
-- TOC entry 1926 (class 0 OID 0)
-- Dependencies: 1555
-- Name: auto_increment; Type: ACL; Schema: dns; Owner: -
--

REVOKE ALL ON SEQUENCE auto_increment FROM PUBLIC;
REVOKE ALL ON SEQUENCE auto_increment FROM master;
GRANT ALL ON SEQUENCE auto_increment TO master;
GRANT USAGE ON SEQUENCE auto_increment TO main;


-- Completed on 2009-10-04 23:54:26 MSD

--
-- PostgreSQL database dump complete
--

