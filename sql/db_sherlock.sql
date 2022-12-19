-- Создание схемы
drop schema if exists sherlock_db cascade;
create schema sherlock_db;

set search_path = sherlock_db;


-- Создание таблиц

-- 1) Place of crime
drop table if exists place_of_crime cascade;
create table place_of_crime
(
    id            serial not null,
    location_city varchar(200),
    Primary key (id)
);

-- 2) Crime
drop table if exists crime cascade;
create table crime
(
    id           serial       not null,
    place_id     int          not null,
    crime_type   varchar(100) not null,
    episode_code varchar(6),
    Primary key (id),
    constraint FK_place_of_crime Foreign Key (place_id) references place_of_crime (id),
    constraint CHK_episode_code check (episode_code similar to 'S[0-9][0-9]E[0-9][0-9]')
);

-- 3) Detective
drop table if exists detective cascade;
create table detective
(
    detective_name varchar(100) not null,
    gender         varchar(10),
    main_jon       varchar(200),
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
    id             serial       not null,
    organizer_name varchar(100) not null,
    description    text,
    motive_type    varchar(100) not null,
    Primary key (id),
    constraint FK_crime_organizer_name Foreign key (organizer_name) references organizer_of_crime (organizer_name)
);

-- 6) Crime victim
drop table if exists crime_victim cascade;
create table crime_victim
(
    id          serial not null,
    victim_name varchar(100),
    gender      varchar(10),
    age         int,
    Primary key (id),
    constraint CHK_gender check (gender in ('Male', 'Female')),
    constraint CHK_victim_age check (age between 0 and 120)
);

-- 7) Crime X Detective
drop table if exists crime_x_detective cascade;
create table crime_x_detective
(
    detective_name          varchar(100) not null,
    crime_id                int          not null,
    valid_from_episode_time time default to_timestamp('00:00:01', 'HH12:MI:SS'),
    valid_to_episode_time   time default to_timestamp('10:00:00', 'HH12:MI:SS'),
    Primary key (detective_name, valid_from_episode_time),
    constraint FK_detective_name Foreign key (detective_name) references detective (detective_name),
    constraint FK_crime_id Foreign key (crime_id) references crime (id)
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
    constraint FK_crime_id Foreign key (crime_id) references crime (id),
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
    constraint FK_crime_id Foreign key (crime_id) references crime (id),
    constraint FK_victim_id Foreign key (victim_id) references crime_victim (id),
    constraint CHK_degree_of_harm check (degree_of_harm in ('Light', 'Average', 'Hard', 'No harm'))
);