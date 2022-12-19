-- Создание схемы
drop schema if exists sherlock_db cascade;
create schema sherlock_db;

set search_path = sherlock_db;


-- Создание таблиц

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


-- Заполнение таблиц

-- 1) Place of crime
insert into place_of_crime(place_id, place_name, location_city)
values (1, 'Abandoned house', 'London');
insert into place_of_crime(place_id, place_name, location_city)
values (2, 'Banker''s flat', 'London');
insert into place_of_crime(place_id, place_name, location_city)
values (3, 'The National Antiquities Museum', 'London');
insert into place_of_crime(place_id, place_name, location_city)
values (4, 'The Chinese circus', 'London');
insert into place_of_crime(place_id, place_name, location_city)
values (5, 'Raven', 'Dartmoor');
insert into place_of_crime(place_id, place_name, location_city)
values (6, 'Village', 'Dartmoor');
insert into place_of_crime(place_id, place_name, location_city)
values (7, 'Church', 'Oxford');


-- 2) Crime
insert into crime(crime_id, crime_name, place_id, crime_type, episode_code)
values (1, 'Suicide of the woman in pink', 1, 'Murder', 'S01E01');
insert into crime(crime_id, crime_name, place_id, crime_type, episode_code)
values (2, 'Murder of a banker', 2, 'Murder', 'S01E02');
insert into crime(crime_id, crime_name, place_id, crime_type, episode_code)
values (3, 'Murder of the Chinese pottery expert', 3, 'Murder', 'S01E02');
insert into crime(crime_id, crime_name, place_id, crime_type, episode_code)
values (4, 'The abduction of John and Sara from the Chinese circus', 4, 'Abduction', 'S01E02');
insert into crime(crime_id, crime_name, place_id, crime_type, episode_code)
values (5, 'Murder of Henry Night''s father', 5, 'Murder', 'S02E02');
insert into crime(crime_id, crime_name, place_id, crime_type, episode_code)
values (6, 'Using of hallucinatory chemical weapon', 6, 'Poisoning', 'S02E02');
insert into crime(crime_id, crime_name, place_id, crime_type, episode_code)
values (7, 'Major Sholto''s case', 7, 'Attempted murder', 'S03E02');


-- 3) Detective
insert into detective(detective_name, gender, main_job)
values ('Sherlock Holmes', 'Male', 'Private detective');
insert into detective(detective_name, gender, main_job)
values ('John Watson', 'Male', 'Military doctor');
insert into detective(detective_name, gender, main_job)
values ('Greg Lestrade', 'Male', 'Detective inspector of Scotland Yard');
insert into detective(detective_name, gender, main_job)
values ('Molly Hooper', 'Female', 'Pathologist in a hospital');
insert into detective(detective_name, gender, main_job)
values ('Mary Watson', 'Female', 'Nurse Assassin');


-- 4) Organizer of crime
insert into organizer_of_crime(organizer_name, gender, crime_gang)
values ('Jim Moriarty', 'Male', 'Moriarty gang');
insert into organizer_of_crime(organizer_name, gender, crime_gang)
values ('Jeff Hope', 'Male', 'Moriarty gang');
insert into organizer_of_crime(organizer_name, gender, crime_gang)
values ('Zhi Zhu', 'Male', 'Black Lotus');
insert into organizer_of_crime(organizer_name, gender, crime_gang)
values ('General Shan', 'Female', 'Black Lotus');
insert into organizer_of_crime(organizer_name, gender, crime_gang)
values ('Bob Frankland', 'Male', 'HOUND project group');
insert into organizer_of_crime(organizer_name, gender)
values ('Jonathan Small', 'Male');


-- 5) Motive
insert into motive(motive_id, organizer_name, motive_description, motive_type)
values (1, 'Jim Moriarty',
        'Moriarty just having fun by organizing crimes',
        'Fun');
insert into motive(motive_id, organizer_name, motive_description, motive_type)
values (2, 'Jeff Hope',
        'Jeff Hope was a taxi driver and had a life-threatening aneurysm that could kill him any time. Jim Moriarty sponsored Jeff''s killing spree, with money going to his children for every life he took.',
        'Money');
insert into motive(motive_id, organizer_name, motive_description, motive_type)
values (3, 'Zhi Zhu',
        'Zhi Zhu carried out the order of the management',
        'Money');
insert into motive(motive_id, organizer_name, motive_description, motive_type)
values (4, 'General Shan',
        'General Shan was looking for a precious hairpin stolen by someone from the staff',
        'Money');
insert into motive(motive_id, organizer_name, motive_description, motive_type)
values (5, 'Bob Frankland',
        'Frankland envied Henry''s father',
        'Jealousy');
insert into motive(motive_id, organizer_name, motive_description, motive_type)
values (6, 'Bob Frankland',
        'Frankland was intimidating Henry so that he could not restore the true events in his memory',
        'Hiding evidence');
insert into motive(motive_id, organizer_name, motive_description, motive_type)
values (7, 'Jonathan Small',
        'Jonathan Small was taking revenge on the major for the death of his brother',
        'Revenge');


-- 6) Crime victim
insert into crime_victim(victim_id, victim_name, gender, age)
values (1, 'Jennifer Wilson', 'Female', 45);
insert into crime_victim(victim_id, victim_name, gender, age)
values (2, 'Edward van Coon', 'Male', 42);
insert into crime_victim(victim_id, victim_name, gender, age)
values (3, 'Soo Lin Yao', 'Female', 24);
insert into crime_victim(victim_id, victim_name, gender, age)
values (4, 'John Watson', 'Male', 34);
insert into crime_victim(victim_id, victim_name, gender, age)
values (5, 'Sarah Sawyer', 'Female', 31);
insert into crime_victim(victim_id, victim_name, gender, age)
values (6, 'Henry Knight', 'Male', 25);
insert into crime_victim(victim_id, victim_name, gender, age)
values (7, 'Henry Knight''s father', 'Male', 43);
insert into crime_victim(victim_id, victim_name, gender, age)
values (8, 'Sherlock Holmes', 'Male', 34);
insert into crime_victim(victim_id, victim_name, gender, age)
values (9, 'Major Sholto', 'Male', 52);


-- 7) Crime X Detective
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Greg Lestrade', 1, '2010-04-03'::date, '2010-04-20'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Sherlock Holmes', 1, '2010-04-03'::date, '2010-04-20'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('John Watson', 1, '2010-04-04'::date, '2010-04-20'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Molly Hooper', 1, '2010-04-06'::date, '2010-04-06'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Sherlock Holmes', 2, '2010-05-07'::date, '2010-05-28'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('John Watson', 2, '2010-05-07'::date, '2010-05-09'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Greg Lestrade', 2, '2010-05-07'::date, '2010-05-09'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Sherlock Holmes', 3, '2010-05-10'::date, '2010-05-13'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('John Watson', 3, '2010-05-10'::date, '2010-05-13'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Sherlock Holmes', 4, '2010-05-14'::date, '2010-05-15'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Sherlock Holmes', 5, '2012-10-24'::date, '2012-10-30'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('John Watson', 5, '2012-10-24'::date, '2012-10-30'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Sherlock Holmes', 6, '2012-10-15'::date, '2012-10-23'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('John Watson', 6, '2012-10-15'::date, '2012-10-23'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Greg Lestrade', 6, '2012-10-10'::date, '2012-10-23'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Sherlock Holmes', 6, '2014-03-11'::date, '2014-03-13'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('John Watson', 6, '2014-03-11'::date, '2014-03-13'::date);
insert into crime_x_detective(detective_name, crime_id, valid_from_date, valid_to_date)
values ('Mary Watson', 6, '2014-03-11'::date, '2014-03-13'::date);


-- 8) Crime X Organizer
insert into crime_x_organizer(crime_id, organizer_name, instrument_of_crime, organizer_punishment_type)
values (1, 'Jeff Hope', 'Poison pills', 'Death');
insert into crime_x_organizer(crime_id, organizer_name, instrument_of_crime, organizer_punishment_type)
values (2, 'Zhi Zhu', 'Gun', 'No punishment');
insert into crime_x_organizer(crime_id, organizer_name, instrument_of_crime, organizer_punishment_type)
values (2, 'General Shan', 'Using other people', 'Death');
insert into crime_x_organizer(crime_id, organizer_name, instrument_of_crime, organizer_punishment_type)
values (3, 'Zhi Zhu', 'Knife', 'No punishment');
insert into crime_x_organizer(crime_id, organizer_name, instrument_of_crime, organizer_punishment_type)
values (3, 'General Shan', 'Using other people', 'Death');
insert into crime_x_organizer(crime_id, organizer_name, instrument_of_crime, organizer_punishment_type)
values (4, 'General Shan', 'Rope', 'Death');
insert into crime_x_organizer(crime_id, organizer_name, instrument_of_crime, organizer_punishment_type)
values (5, 'Bob Frankland', 'Gun', 'No punishment');
insert into crime_x_organizer(crime_id, organizer_name, instrument_of_crime, organizer_punishment_type)
values (6, 'Bob Frankland', 'Laboratory devices', 'Death');
insert into crime_x_organizer(crime_id, organizer_name, instrument_of_crime, organizer_punishment_type)
values (7, 'Jonathan Small', 'Blade', 'Arrest');


-- 9) Crime X Victim
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (1, 1, 'Hard');
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (2, 2, 'Hard');
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (3, 3, 'Hard');
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (4, 4, 'Light');
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (4, 5, 'Light');
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (5, 6, 'Average');
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (5, 7, 'Hard');
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (6, 6, 'Average');
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (6, 4, 'Light');
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (6, 7, 'Average');
insert into crime_x_victim(crime_id, victim_id, degree_of_harm)
values (7, 9, 'Average');