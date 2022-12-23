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
       overlay(dt.main_job placing '*****' from 1 for 10000)     as detective_main_job
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
       overlay(ooc.crime_gang placing '*****' from 2 for 1000)    as organizer_gang
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
select overlay(cxd.detective_name placing '*****' from 2 for 100) as detective_name,
       cxd.crime_id,
       cxd.valid_from_date,
       cxd.valid_to_date
from sherlock_db.crime_x_detective cxd;

-- 8) Crime X Organizer
drop view if exists v_crime_x_organizer;
create view v_crime_x_organizer as
select cxo.crime_id,
       overlay(cxo.organizer_name placing '*****' from 2 for 100)             as organizer_name,
       cxo.instrument_of_crime,
       overlay(cxo.organizer_punishment_type placing '*****' from 1 for 1000) as organizer_punishment_type
from sherlock_db.crime_x_organizer cxo;

-- 9) Crime X Victim
drop view if exists v_crime_x_victim;
create view v_crime_x_victim as
select *
from sherlock_db.crime_x_victim;


-- Creating complex views

-- (1)
-- For each gang, output statistics on it:
-- crime gang name;
-- most often crime type, that this gang committed -- if several types occur the same number of times and they are the most popular for this gang, output both crime types;
-- count of the most often crime type for gang; count of crime organizers of this gang;
-- and statistics about victims ages of this gang: min victim age, max victim age and average victim age

with gangs_victims_ages as (select distinct ooc.crime_gang as crime_gang,
                                            cv.victim_id,
                                            cv.age         as victim_age
                            from sherlock_db.organizer_of_crime ooc
                                     inner join
                                 sherlock_db.crime_x_organizer cxo on ooc.organizer_name = cxo.organizer_name
                                     inner join
                                 sherlock_db.crime cr on cxo.crime_id = cr.crime_id
                                     inner join
                                 sherlock_db.crime_x_victim cxv on cr.crime_id = cxv.crime_id
                                     inner join
                                 sherlock_db.crime_victim cv on cxv.victim_id = cv.victim_id
                            where ooc.crime_gang is not null),
     victim_ages_statistics as (select distinct gva.crime_gang,
                                                min(gva.victim_age) over (partition by gva.crime_gang)  as min_gang_victim_age,
                                                max(gva.victim_age) over (partition by gva.crime_gang)  as max_gang_victim_age,
                                                sum(gva.victim_age) over (partition by gva.crime_gang) /
                                                count(gva.victim_id) over (partition by gva.crime_gang) as average_gang_victim_age
                                from gangs_victims_ages gva),
     organizers_count as (select ooc.crime_gang,
                                 count(ooc.organizer_name) over (partition by ooc.crime_gang) as cnt_organizers
                          from sherlock_db.organizer_of_crime ooc),
     gangs_crime_types as (select distinct ooc.crime_gang as crime_gang,
                                           cr.crime_id,
                                           cr.crime_type  as crime_type
                           from sherlock_db.organizer_of_crime ooc
                                    inner join
                                sherlock_db.crime_x_organizer cxo on ooc.organizer_name = cxo.organizer_name
                                    inner join
                                sherlock_db.crime cr on cxo.crime_id = cr.crime_id
                           where ooc.crime_gang is not null),
     gangs_crime_types_statistics as (select distinct gct.crime_gang                                               as crime_gang,
                                                      gct.crime_type                                               as crime_type,
                                                      count(crime_type) over (partition by crime_gang, crime_type) as gang_crime_type_count
                                      from gangs_crime_types gct),
     gang_crime_type_rank as (select crime_gang,
                                     crime_type,
                                     gang_crime_type_count,
                                     dense_rank()
                                     over (partition by gcts.crime_gang order by gcts.gang_crime_type_count desc) as type_count_rank
                              from gangs_crime_types_statistics gcts),
     gang_max_crime_type as (select crime_gang,
                                    crime_type,
                                    gang_crime_type_count
                             from gang_crime_type_rank
                             where type_count_rank = 1)
select distinct vas.crime_gang,
                gmct.crime_type            as most_often_crime_type,
                gmct.gang_crime_type_count as cnt_most_often_crime_type,
                oc.cnt_organizers,
                vas.min_gang_victim_age,
                vas.max_gang_victim_age,
                vas.average_gang_victim_age
from victim_ages_statistics vas
         inner join organizers_count oc on vas.crime_gang = oc.crime_gang
         inner join gang_max_crime_type gmct on vas.crime_gang = gmct.crime_gang;


-- (2)
-- For each crime, output a summary of the data on it:
-- crime name; crime type; crime place; all victims, organizers and detectives of crime -- each group is output as an array in one cell of the table;
-- episode code of crime of TV series.
-- Than sort crimes in asc order of episode codes

drop view if exists v_crime_statistics;
create view v_crime_statistics as
select cr.crime_name,
       cr.crime_type,
       poc.place_name                         as crime_place,
       array_agg(distinct cv.victim_name)     as crime_victims,
       array_agg(distinct ooc.organizer_name) as crime_organizers,
       array_agg(distinct cxd.detective_name) as crime_detectives,
       cr.episode_code                        as crime_episode_code
from sherlock_db.crime cr
         left join
     sherlock_db.crime_x_victim cxv on cr.crime_id = cxv.crime_id
         left join
     sherlock_db.crime_victim cv on cxv.victim_id = cv.victim_id
         left join
     sherlock_db.place_of_crime poc on cr.place_id = poc.place_id
         left join
     sherlock_db.crime_x_organizer cxo on cr.crime_id = cxo.crime_id
         left join
     sherlock_db.organizer_of_crime ooc on cxo.organizer_name = ooc.organizer_name
         left join
     sherlock_db.crime_x_detective cxd on cr.crime_id = cxd.crime_id
group by cr.crime_id, episode_code, crime_place
order by cr.episode_code;
