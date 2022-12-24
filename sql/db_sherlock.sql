-- Schema creating
drop schema if exists sherlock_db cascade;
create schema sherlock_db;

set search_path = sherlock_db;


-- Tables creating (TASK 3)

-- 1) Place of crime
drop table if exists place_of_crime cascade;
create table place_of_crime
(
    place_id      serial not null,
    place_name    varchar(200),
    location_city varchar(200),
    Primary key (place_id)
);

-- 2) Crime
drop table if exists crime cascade;
create table crime
(
    crime_id     serial       not null,
    crime_name   varchar(100) not null,
    place_id     int          not null,
    crime_type   varchar(100) not null,
    episode_code varchar(6),
    Primary key (crime_id),
    constraint FK_place_of_crime Foreign Key (place_id) references place_of_crime (place_id),
    constraint CHK_episode_code check (episode_code similar to 'S[0-9][0-9]E[0-9][0-9]')
);

-- 3) Detective
drop table if exists detective cascade;
create table detective
(
    detective_name varchar(100) not null,
    gender         varchar(10),
    main_job       varchar(200),
    Primary key (detective_name),
    constraint CHK_gender check (gender in ('Male', 'Female'))
);

-- 4) Organizer of crime
drop table if exists organizer_of_crime cascade;
create table organizer_of_crime
(
    organizer_name varchar(100) not null,
    gender         varchar(10),
    crime_gang     text,
    Primary key (organizer_name),
    constraint CHK_gender check (gender in ('Male', 'Female'))
);

-- 5) Motive
drop table if exists motive cascade;
create table motive
(
    motive_id          serial       not null,
    organizer_name     varchar(100) not null,
    motive_description text,
    motive_type        varchar(100) not null,
    Primary key (motive_id),
    constraint FK_crime_organizer_name Foreign key (organizer_name) references organizer_of_crime (organizer_name)
);

-- 6) Crime victim
drop table if exists crime_victim cascade;
create table crime_victim
(
    victim_id   serial not null,
    victim_name varchar(100),
    gender      varchar(10),
    age         int,
    Primary key (victim_id),
    constraint CHK_gender check (gender in ('Male', 'Female')),
    constraint CHK_victim_age check (age between 0 and 120)
);

-- 7) Crime X Detective
drop table if exists crime_x_detective cascade;
create table crime_x_detective
(
    detective_name  varchar(100) not null,
    crime_id        int,
    valid_from_date date         not null,
    valid_to_date   date default to_date('9999-01-01', 'YYYY-MM-DD'),
    Primary key (detective_name, valid_from_date),
    constraint FK_detective_name Foreign key (detective_name) references detective (detective_name),
    constraint FK_crime_id Foreign key (crime_id) references crime (crime_id)
);

-- 8) Crime X Organizer
drop table if exists crime_x_organizer cascade;
create table crime_x_organizer
(
    crime_id                  int          not null,
    organizer_name            varchar(100) not null,
    instrument_of_crime       varchar(200),
    organizer_punishment_type varchar(200),
    Primary key (crime_id, organizer_name),
    constraint FK_crime_id Foreign key (crime_id) references crime (crime_id),
    constraint FK_organizer_name Foreign key (organizer_name) references organizer_of_crime (organizer_name)
);

-- 9) Crime X Victim
drop table if exists crime_x_victim cascade;
create table crime_x_victim
(
    crime_id       int not null,
    victim_id      int not null,
    degree_of_harm varchar(20),
    Primary key (crime_id, victim_id),
    constraint FK_crime_id Foreign key (crime_id) references crime (crime_id),
    constraint FK_victim_id Foreign key (victim_id) references crime_victim (victim_id),
    constraint CHK_degree_of_harm check (degree_of_harm in ('Light', 'Average', 'Hard'))
);


-- Tables filling (TASK 4)

-- 1) Place of crime
insert into place_of_crime(place_id, place_name, location_city)
values (1, 'Abandoned house', 'London'),
       (2, 'Banker''s flat', 'London'),
       (3, 'The National Antiquities Museum', 'London'),
       (4, 'The Chinese circus', 'London'),
       (5, 'Raven', 'Dartmoor'),
       (6, 'Village', 'Dartmoor'),
       (7, 'Church', 'Oxford');

-- 2) Crime
insert into crime(crime_id, crime_name, place_id, crime_type, episode_code)
values (1, 'Suicide of the woman in pink', 1, 'Murder', 'S01E01'),
       (2, 'Murder of a banker', 2, 'Murder', 'S01E02'),
       (3, 'Murder of the Chinese pottery expert', 3, 'Murder', 'S01E02'),
       (4, 'The abduction of John and Sara from the Chinese circus', 4, 'Abduction', 'S01E02'),
       (5, 'Murder of Henry Night''s father', 5, 'Murder', 'S02E02'),
       (6, 'Using of hallucinatory chemical weapon', 6, 'Poisoning', 'S02E02'),
       (7, 'Major Sholto''s case', 7, 'Attempted murder', 'S03E02');

-- 3) Detective
insert into detective(detective_name, gender, main_job)
values ('Sherlock Holmes', 'Male', 'Private detective'),
       ('John Watson', 'Male', 'Military doctor'),
       ('Greg Lestrade', 'Male', 'Detective inspector of Scotland Yard'),
       ('Molly Hooper', 'Female', 'Pathologist in a hospital'),
       ('Mary Watson', 'Female', 'Nurse Assassin');

-- 4) Organizer of crime
insert into organizer_of_crime(organizer_name, gender, crime_gang)
values ('Jim Moriarty', 'Male', 'Moriarty gang'),
       ('Jeff Hope', 'Male', 'Moriarty gang'),
       ('Zhi Zhu', 'Male', 'Black Lotus'),
       ('Shan Yan', 'Female', 'Black Lotus'),
       ('Bob Frankland', 'Male', 'HOUND project group');
insert into organizer_of_crime(organizer_name, gender)
values ('Jonathan Small', 'Male');

-- 5) Motive
insert into motive(motive_id, organizer_name, motive_description, motive_type)
values (1, 'Jim Moriarty',
        'Criminal just having fun by organizing crimes',
        'Fun'),
       (2, 'Jeff Hope',
        'Criminal had a life-threatening aneurysm that could kill him any time. Jim Moriarty sponsored criminal''s killing spree, with money going to his children for every life he took.',
        'Money'),
       (3, 'Zhi Zhu',
        'Crimial carried out the order of the management',
        'Money'),
       (4, 'Shan Yan',
        'Criminal was looking for a precious hairpin stolen by someone from the staff',
        'Money'),
       (5, 'Bob Frankland',
        'Criminal envied Henry''s father',
        'Jealousy'),
       (6, 'Bob Frankland',
        'Criminal was intimidating Henry so that he could not restore the true events in his memory',
        'Jealousy'), -- Hiding evidence
       (7, 'Jonathan Small',
        'Criminal was taking revenge on the major for the death of his brother',
        'Revenge');

-- 6) Crime victim
insert into crime_victim(victim_id, victim_name, gender, age)
values (1, 'Jennifer Wilson', 'Female', 45),
       (2, 'Edward van Coon', 'Male', 42),
       (3, 'Soo Lin Yao', 'Female', 24),
       (4, 'John Watson', 'Male', 34),
       (5, 'Sarah Sawyer', 'Female', 31),
       (6, 'Henry Knight', 'Male', 25),
       (7, 'Martin Knight', 'Male', 43),
       (8, 'Sherlock Holmes', 'Male', 34),
       (9, 'Major Sholto', 'Male', 52);

-- 7) Crime X Detective
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Greg Lestrade', 1, '2010-04-03'::date, '2049-04-20'::date),
       ('Sherlock Holmes', 1, '2010-04-03'::date, '2010-04-20'::date),
       ('John Watson', 1, '2010-04-04'::date, '2010-04-20'::date),
       ('Molly Hooper', 1, '2010-04-06'::date, '2010-04-06'::date),
       ('Sherlock Holmes', 2, '2010-05-07'::date, '2010-05-28'::date),
       ('John Watson', 2, '2010-05-07'::date, '2010-05-09'::date),
       ('Greg Lestrade', 2, '2010-05-07'::date, '2010-05-09'::date),
       ('Sherlock Holmes', 3, '2010-05-10'::date, '2010-05-13'::date),
       ('John Watson', 3, '2010-05-10'::date, '2010-05-13'::date),
       ('Sherlock Holmes', 4, '2010-05-14'::date, '2010-05-15'::date),
       ('Sherlock Holmes', 5, '2012-10-24'::date, '2012-10-30'::date),
       ('John Watson', 5, '2012-10-24'::date, '2012-10-30'::date),
       ('Sherlock Holmes', 6, '2012-10-15'::date, '2012-10-23'::date),
       ('John Watson', 6, '2012-10-15'::date, '2012-10-23'::date),
       ('Greg Lestrade', 6, '2012-10-10'::date, '2012-10-23'::date),
       ('Sherlock Holmes', 7, '2014-03-11'::date, '2014-03-13'::date),
       ('John Watson', 7, '2014-03-11'::date, '2014-03-13'::date),
       ('Mary Watson', 7, '2014-03-11'::date, '2014-03-13'::date);

-- 8) Crime X Organizer
insert into crime_x_organizer(crime_id, organizer_name, instrument_of_crime, organizer_punishment_type)
values (1, 'Jeff Hope', 'Poison pills', 'Death'),
       (2, 'Zhi Zhu', 'Gun', 'No punishment'),
       (2, 'Shan Yan', 'Using other people', 'Death'),
       (3, 'Zhi Zhu', 'Knife', 'No punishment'),
       (3, 'Shan Yan', 'Using other people', 'Death'),
       (4, 'Shan Yan', 'Rope', 'Death'),
       (5, 'Bob Frankland', 'Gun', 'No punishment'),
       (6, 'Bob Frankland', 'Laboratory devices', 'Death'),
       (7, 'Jonathan Small', 'Blade', 'Arrest');

-- 9) Crime X Victim
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (1, 1, 'Hard'),
       (2, 2, 'Hard'),
       (3, 3, 'Hard'),
       (4, 4, 'Light'),
       (4, 5, 'Light'),
       (5, 6, 'Average'),
       (5, 7, 'Hard'),
       (6, 6, 'Average'),
       (6, 4, 'Light'),
       (6, 7, 'Average'),
       (7, 9, 'Average');


-- CRUD-requests (TASK 5)

-- for table 'Detective'
insert into detective(detective_name, gender, main_job)
values ('Mycroft Holmes', 'Male', 'Member of the Government');

insert into detective(detective_name, gender, main_job)
values ('Marta Hudson', 'Female', 'Landlady');

insert into detective(detective_name, gender, main_job)
values ('Ben Hudson', 'Male', 'Landlord');

select detective_name,
       main_job
from detective
where gender = 'Male';

update
    detective
set main_job = 'Member of the British Government'
where detective_name = 'Mycroft Holmes';

delete
from detective
where (detective_name similar to '%Hudson')
  and (gender = 'Male');

select detective_name
from detective
where detective_name similar to '%Hudson';

-- for table 'Crime victim'
insert into crime_victim(victim_id, victim_name, gender, age)
values (10, 'Brian Lukis', 'Male', 55);

insert into crime_victim(victim_id, victim_name, gender, age)
values (11, 'Charlie Welsborough', 'Male', 70);

update
    crime_victim
set age = 60
where victim_name = 'Brian Lukis';

select victim_name,
       age
from crime_victim
where age between 30 and 40;

delete
from crime_victim
where age > 59;


-- Requests to db (TASK 6)

-- (1)
-- Для каждого преступления вывести дату начала расследования (когда первый из детективов дела начал работу над преступлением)
-- дату окончания расследования (если еще не окончено -- вывести дату из далекого будущего)
-- продолжительность расследования на текущий момент, выраженную в днях
-- во сколько раз расследование текущего преступление производилось дольше, чем расследование следующего за ним по дате преступления
-- Отсортировать полученные в результате преступления в порядке убывания продолжительности их расследования
-- и затем в порядке возрастания даты начала расследования

with crimes_dates as (select cr.crime_name                              as crime_name,
                             min(cxd.valid_from_date)                   as investigation_start_date,
                             max(cxd.valid_to_date)                     as investigation_end_date,
                             least(max(cxd.valid_to_date), now()::date) as investigation_end_date_or_now
                      from detective dt
                               inner join
                           crime_x_detective cxd on dt.detective_name = cxd.detective_name
                               inner join
                           crime cr on cxd.crime_id = cr.crime_id
                      group by cr.crime_id),
     crimes_duration as (select *,
                                (cd.investigation_end_date_or_now - cd.investigation_start_date) as investigation_duration
                         from crimes_dates cd),
     next_duration as (select *,
                              lead(cd.investigation_duration, 1, 0)
                              over (order by cd.investigation_start_date) as next_crime_duration
                       from crimes_duration cd)
select cd.crime_name,
       cd.investigation_start_date,
       cd.investigation_end_date,
       cd.investigation_duration,
       (cd.investigation_duration - cd.next_crime_duration) as diff_w_next_crime_duration
from next_duration cd
order by investigation_duration desc, investigation_start_date;


-- (2)
-- Для каждого организатора преступлений, кто совершил хотя бы одно убийство,
-- вывести количество совершенных им убийств и ранговый номер среди всех убийц в порядке количества убийств.
-- Отсортировать организаторов в порядке убывания числа убийств и затем в алфавитном порядке по имени.

with organizers_mudrers_cnt as (select ooc.organizer_name as organizer_name,
                                       count(cr.crime_id) as murders_count
                                from organizer_of_crime ooc
                                         inner join
                                     crime_x_organizer cxo on ooc.organizer_name = cxo.organizer_name
                                         inner join
                                     crime cr on cxo.crime_id = cr.crime_id
                                where cr.crime_type = 'Murder'
                                group by ooc.organizer_name
                                having count(cr.crime_id) > 1)
select omc.organizer_name,
       omc.murders_count,
       dense_rank() over (order by murders_count) as murder_cnt_dense_rank
from organizers_mudrers_cnt omc
order by murders_count desc, organizer_name;


-- (3)
-- Для каждого организатора вывести тип мотива, который встречался в его преступлениях чаще всего.
-- Отсортировать организаторов в алфавитном порядке по имени.

with organizer_motive as (select ooc.organizer_name as organizer_name,
                                 mt.motive_type     as motive_type
                          from organizer_of_crime ooc
                                   inner join
                               motive mt on ooc.organizer_name = mt.organizer_name),
     organizer_motive_cnt as (select distinct owm.organizer_name,
                                              owm.motive_type,
                                              count(owm.motive_type)
                                              over (partition by owm.organizer_name, owm.motive_type) as organizer_motive_cnt
                              from organizer_motive owm),
     organizer_max_motive_type as (select omc.organizer_name,
                                          max(omc.organizer_motive_cnt) over (partition by omc.organizer_name) as max_org_motive_cnt
                                   from organizer_motive_cnt omc)
select omc.organizer_name as organizer_name,
       omc.motive_type    as most_often_motive_type
from organizer_motive_cnt omc
         inner join organizer_max_motive_type ommt on omc.organizer_name = ommt.organizer_name
where omc.organizer_motive_cnt = ommt.max_org_motive_cnt
order by organizer_name;


-- (4)
-- Вывести организаторов преступления, у которых суммарное число жертв во всех преступлениях > 3 (с возможными повторениями жертв;
-- интересуемся именно тем, сколько раз организатор навредил кому-либо), и которые совершили хотя бы одно преступление в Лондоне.

-- организаторы, у которых суммарное число жертв во всех преступлениях > 3
with org_w_crime_victims_cnt as (select ooc.organizer_name   as organizer_name,
                                        cr.crime_id          as crime_id,
                                        count(cxv.victim_id) as victims_cnt
                                 from organizer_of_crime ooc
                                          inner join
                                      crime_x_organizer cxo on ooc.organizer_name = cxo.organizer_name
                                          inner join crime cr on cxo.crime_id = cr.crime_id
                                          inner join crime_x_victim cxv on cr.crime_id = cxv.crime_id
                                 group by ooc.organizer_name, cr.crime_id),
     org_victims_sum as (select distinct owc.organizer_name,
                                         sum(owc.victims_cnt) over (partition by owc.organizer_name) as org_victims_sum_cnt
                         from org_w_crime_victims_cnt owc)
select ovs.organizer_name
from org_victims_sum ovs
where ovs.org_victims_sum_cnt > 3

intersect

-- организаторы, которые совершили хотя бы одно преступление в Лондоне
select distinct ooc.organizer_name
from organizer_of_crime ooc
         inner join
     crime_x_organizer cxo on ooc.organizer_name = cxo.organizer_name
         inner join
     crime cr on cxo.crime_id = cr.crime_id
         inner join
     place_of_crime poc on cr.place_id = poc.place_id
where poc.location_city = 'London';


-- (5)
-- Для каждого детектива вывести имя и возраст самой младшей жертвы, которая встречалась в расследуемых им преступлениях.
-- Если несколько жертв имеют один и тот же возраст и они являются самыми младшими для следователя, вывести всех.
-- Отсортировать результат в алфавитном порядке по имени следователя.

with detective_victims_age as (select dt.detective_name as detective_name,
                                      cv.victim_name as victim_name,
                                      cv.age as victim_age,
                                      dense_rank() over (partition by dt.detective_name order by cv.age) as victims_age_rank
                               from detective dt
                                        inner join
                                    crime_x_detective cxd on dt.detective_name = cxd.detective_name
                                        inner join
                                    crime cr on cr.crime_id = cxd.crime_id
                                        inner join
                                    crime_x_victim cxv on cr.crime_id = cxv.crime_id
                                        inner join
                                    crime_victim cv on cxv.victim_id = cv.victim_id)
select
    dva.detective_name,
    dva.victim_name,
    dva.victim_age
from
    detective_victims_age dva
where
    dva.victims_age_rank = 1
order by
    detective_name;
