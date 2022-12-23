-- Creating new schema for views

drop schema if exists sherlock_db_views cascade;
create schema sherlock_db_views;

set search_path = sherlock_db_views;


-- Creating views for each table

-- 1) Place of crime
drop view if exists v_place_of_crime;
create view v_place_of_crime as
select poc.place_name,
       poc.location_city
from sherlock_db.place_of_crime poc;

-- 2) Crime
drop view if exists v_crime;
create view v_crime as
select cr.crime_name,
       cr.crime_type,
       cr.episode_code
from sherlock_db.crime cr;

-- 3) Detective
drop view if exists v_detective;
create view v_detective as
select case
           when gender = 'Male' then 'Mr. '
           when gender = 'Female' then 'Ms. '
           else ''
           end
           ||
       overlay(dt.detective_name placing '*****' from 2 for 100) as detective_name,
       overlay(dt.main_job placing '*****' from 1 for 10000) as detective_main_job
from sherlock_db.detective dt;

-- 4) Organizer of crime
drop view if exists v_organizer_of_crime;
create view v_organizer_of_crime as
select case
           when gender = 'Male' then 'Mr. '
           when gender = 'Female' then 'Ms. '
           else ''
           end
           ||
       overlay(ooc.organizer_name placing '*****' from 2 for 100) as organizer_name,
       overlay(ooc.crime_gang placing '*****' from 2 for 1000)   as organizer_gang
from sherlock_db.organizer_of_crime ooc;

-- 5) Motive
drop view if exists v_motive;
create view v_motive as
select overlay(mt.organizer_name placing '*****' from 2 for 100) as organizer_name,
       mt.motive_description,
       mt.motive_type
from sherlock_db.motive mt;

-- 6) Crime victim
drop view if exists v_crime_victim;
create view v_crime_victim as
select case
           when gender = 'Male' then 'Mr. '
           when gender = 'Female' then 'Ms. '
           else ''
           end
           ||
       overlay(cv.victim_name placing '*****' from 2 for 100) as victim_name,
       cv.age
from sherlock_db.crime_victim cv;

-- 7) Crime X Detective
drop view if exists v_crime_x_detective;
create view v_crime_x_detective as
select
    overlay(cxd.detective_name placing '*****' from 2 for 100) as detective_name,
    cxd.crime_id,
    cxd.valid_from_date,
    cxd.valid_to_date
from sherlock_db.crime_x_detective cxd;

-- 8) Crime X Organizer
drop view if exists v_crime_x_organizer;
create view v_crime_x_organizer as
select
    cxo.crime_id,
    overlay(cxo.organizer_name placing '*****' from 2 for 100) as organizer_name,
    cxo.instrument_of_crime,
    overlay(cxo.organizer_punishment_type placing '*****' from 1 for 1000) as organizer_punishment_type
from sherlock_db.crime_x_organizer cxo;

-- 9) Crime X Victim
drop view if exists v_crime_x_victim;
create view v_crime_x_victim as
select *
from sherlock_db.crime_x_victim;