--
-- PostgreSQL database dump
--

-- Started on 2009-10-05 00:03:01 MSD

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 4330 (class 1262 OID 16384)
-- Name: stats; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE stats WITH TEMPLATE = template0 ENCODING = 'UTF8';


\connect stats

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 6 (class 2615 OID 32816)
-- Name: dummies; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA dummies;


--
-- TOC entry 10 (class 2615 OID 45736)
-- Name: mviews; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mviews;


--
-- TOC entry 1411 (class 2612 OID 19321)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE PROCEDURAL LANGUAGE plpgsql;


SET search_path = dummies, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 2952 (class 1259 OID 32842)
-- Dependencies: 3954 3955 6
-- Name: past_n_days; Type: TABLE; Schema: dummies; Owner: -; Tablespace: 
--

CREATE TABLE past_n_days (
    day character varying(10) NOT NULL,
    hits integer DEFAULT 0,
    uq integer DEFAULT 0
);


--
-- TOC entry 2951 (class 1259 OID 32817)
-- Dependencies: 3952 3953 6
-- Name: per_day; Type: TABLE; Schema: dummies; Owner: -; Tablespace: 
--

CREATE TABLE per_day (
    hour character varying(10) NOT NULL,
    hits integer DEFAULT 0,
    uq integer DEFAULT 0
);


SET search_path = public, pg_catalog;

--
-- TOC entry 2954 (class 1259 OID 55437)
-- Dependencies: 3957 3
-- Name: income; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE income (
    amount real,
    domain character varying(64),
    logdate timestamp without time zone DEFAULT (now())::timestamp without time zone
);


--
-- TOC entry 2953 (class 1259 OID 46188)
-- Dependencies: 3956 3
-- Name: number_of_sites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE number_of_sites (
    logdate timestamp without time zone DEFAULT now(),
    number integer,
    active integer
);


--
-- TOC entry 2583 (class 1259 OID 22401)
-- Dependencies: 3221 3
-- Name: shows; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shows (
    domain character varying(64),
    ip inet,
    returned boolean,
    logdate timestamp without time zone DEFAULT now()
);


--
-- TOC entry 1035 (class 1247 OID 32814)
-- Dependencies: 3 2950
-- Name: stats_per_hour; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE stats_per_hour AS (
	ahour character varying(10),
	visits integer,
	uq integer
);


--
-- TOC entry 1033 (class 1247 OID 32798)
-- Dependencies: 3 2949
-- Name: stats_total; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE stats_total AS (
	domain character varying(64),
	visits integer,
	uq integer
);


--
-- TOC entry 30 (class 1255 OID 37238)
-- Dependencies: 1033 1411 3
-- Name: get_stats(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_stats(p_from timestamp with time zone, p_to timestamp with time zone) RETURNS SETOF stats_total
    AS $$
declare
	v_rec stats_total;
	v_sum stats_total;
	v_from timestamp without time zone;
	v_to timestamp without time zone;
begin
	v_from = cast(p_from as timestamp without time zone);
	v_to = cast(p_to as timestamp without time zone);
	create temporary table tmp as SELECT shows.domain as "domain", count(*) AS "visits", uq.visits as "uq"
				FROM shows
				LEFT JOIN (SELECT domain, count(*) as visits from shows where logdate >= v_from and logdate < v_to and returned = false group by domain) uq on shows.domain = uq.domain
				WHERE logdate >= v_from and logdate < v_to
				GROUP BY shows.domain, uq.visits;
	update tmp set uq = 0 where uq is null;
	select 'TOTAL' as domain, 0 as visits, 0 as uq into v_sum;
	for v_rec in select * from tmp loop
		v_sum.visits = v_sum.visits + v_rec.visits;
		v_sum.uq = v_sum.uq + v_rec.uq;
		return next v_rec;
	end loop;
	return next v_sum;
	drop table tmp;
	return;
end;
$$
    LANGUAGE plpgsql;


--
-- TOC entry 31 (class 1255 OID 37239)
-- Dependencies: 1411 3 1037
-- Name: get_stats_by_hours(timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_stats_by_hours(p_day timestamp with time zone) RETURNS SETOF dummies.per_day
    AS $$
declare
	v_rec dummies.per_day%rowtype;
	v_day timestamp;
begin
	--v_day = date_trunc('days', p_day at time zone 'UTC');
	v_day = cast(p_day as timestamp without time zone);
	lock table dummies.per_day in exclusive mode;
	update dummies.per_day set hits = 0, uq = 0;
	raise notice 'bI!!!!!';
	for v_rec in  select hits.strdate, hits.visits, count(*) as visits FROM shows
				left join (
					  SELECT to_char(shows.logdate,'hh24') as strdate, count(*) as visits FROM shows WHERE shows.logdate >= v_day AND shows.logdate < v_day + interval '1 day' group by strdate
					)  hits on hits.strdate = to_char(shows.logdate,'hh24')
				WHERE shows.logdate >= v_day AND shows.logdate < v_day + interval '1 day' and returned = false
				GROUP BY hits.strdate, hits.visits
				ORDER BY hits.strdate ASC loop
		raise notice 'v_rec.hits = %, v_rec.uq = %, v_rec.hour = %', v_rec.hits, v_rec.uq, v_rec.hour;
		update dummies.per_day set hits = v_rec.hits, uq = v_rec.uq where hour = v_rec.hour;
	end loop;
	return query select * from dummies.per_day order by hour asc;
end;
$$
    LANGUAGE plpgsql;


--
-- TOC entry 29 (class 1255 OID 32849)
-- Dependencies: 1039 1411 3
-- Name: get_stats_past_n_days(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_stats_past_n_days(p_days integer) RETURNS SETOF dummies.past_n_days
    AS $$
declare
	v_rec dummies.past_N_days%rowtype;
begin
	lock table dummies.past_N_days in exclusive mode;
	delete from dummies.past_N_days;
	for i in 0..p_days loop
		insert into dummies.past_N_days
		  values(to_char(date 'today' - i * interval '1 day', 'dd.MM.yyyy'), 0, 0);
	end loop;
	for v_rec in  SELECT hits.strdate, hits.visits, count(*) FROM shows
			LEFT JOIN (SELECT to_char(logdate,'dd.MM.yyyy') as strdate, count(*) as visits FROM shows
				WHERE shows.logdate >= date 'today' at time zone 'UTC'- p_days * interval '1 day' AND shows.logdate < date 'today' at time zone 'UTC' + interval '1 day'
				GROUP BY strdate) as hits on hits.strdate = to_char(shows.logdate,'dd.MM.yyyy')
			WHERE shows.logdate >= date 'today' at time zone 'UTC' at time zone 'UTC'- p_days * interval '1 day' AND shows.logdate < date 'today' at time zone 'UTC' + interval '1 day'
				AND returned = false
			GROUP BY hits.strdate, hits.visits
			ORDER BY hits.strdate DESC loop
		update dummies.past_N_days set hits = v_rec.hits, uq = v_rec.uq where day = v_rec.day;
	end loop;
	SET DATESTYLE = DMY;
	return query select * from dummies.past_N_days order by day::date asc;
end;
$$
    LANGUAGE plpgsql;


SET search_path = dummies, pg_catalog;

--
-- TOC entry 4326 (class 2606 OID 32848)
-- Dependencies: 2952 2952
-- Name: past_n_days_pkey; Type: CONSTRAINT; Schema: dummies; Owner: -; Tablespace: 
--

ALTER TABLE ONLY past_n_days
    ADD CONSTRAINT past_n_days_pkey PRIMARY KEY (day);


--
-- TOC entry 4324 (class 2606 OID 32823)
-- Dependencies: 2951 2951
-- Name: per_day_pkey; Type: CONSTRAINT; Schema: dummies; Owner: -; Tablespace: 
--

ALTER TABLE ONLY per_day
    ADD CONSTRAINT per_day_pkey PRIMARY KEY (hour);


SET search_path = public, pg_catalog;

--
-- TOC entry 4332 (class 0 OID 0)
-- Dependencies: 3
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2009-10-05 00:04:35 MSD

--
-- PostgreSQL database dump complete
--

