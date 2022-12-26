-- Setting search path
set search_path = sherlock_db;

-- Creating triggers (TASK 9)

-- (1) trigger for table 'Detective'
-- update or insert detective

create or replace function check_insert_or_update_crime_detective()
    returns trigger as
$$
begin
    if (tg_op = 'UPDATE') then
        -- check gender
        if not (new.gender = 'Male' or new.gender = 'Female') then
            raise exception 'Incorrect new detective gender';
        end if;

        if ((select count(*)
             from detective
             where detective_name = new.detective_name) = 0) then
            raise exception 'That detective does not exist';
        end if;
    elsif (tg_op = 'INSERT') then
        -- check gender
        if not (new.gender = 'Male' or new.gender = 'Female') then
            raise exception 'Incorrect detective gender';
        end if;

        -- check detective existing
        if ((select count(*)
             from detective
             where detective_name = new.detective_name) != 0) then
            raise exception 'That detective already exists';
        end if;
    end if;

    return new;
end;
$$ language plpgsql;

-- trigger
create or replace trigger t_check_insert_or_update_detective
    before insert or update
    on detective
    for each row
execute procedure check_insert_or_update_crime_detective();

-- test cases for trigger (1)

-- incorrect detective gender
-- insert into detective(detective_name, gender, main_job)
-- values ('Ever Holmes', 'www', 'Violinist');

-- correct insertion
insert into detective(detective_name, gender, main_job)
values ('Ever Holmes', 'Female', 'Violinist');

-- incorrect updating
-- update detective set gender = 'w' where detective_name = 'Ever Holmes';

-- correct updating
update detective
set main_job = 'The head of the prison'
where detective_name = 'Ever Holmes';


-- (2) trigger on table 'Crime X Detective'
-- update crime_x_detective

-- function for trigger
create or replace function check_update_crime_x_detective()
    returns trigger as
$$
begin
    -- check detective name
    if (select count(*)
        from detective
        where detective.detective_name = new.detective_name) = 0 then
        raise exception 'There is no detective with that detective name';
    end if;

    -- check crime id
    if (select count(*)
        from crime
        where crime.crime_id = new.crime_id) = 0 then
        raise exception 'There is no crime with that crime id';
    end if;

    -- check date to > date from
    if (new.valid_to_date::date < new.valid_from_date::date or new.valid_to_date::date < old.valid_from_date::date) then
        raise exception 'Date_to could not be after date from';
    end if;

    return new;
end;
$$
    language plpgsql;

-- trigger
create or replace trigger t_check_crime_x_detective
    before update
    on crime_x_detective
    for each row
execute procedure check_update_crime_x_detective();

-- test cases for trigger (2)

-- incorrect crime id updating

-- update crime_x_detective
-- set crime_id = 130
-- where detective_name = 'Greg Lestrade'
--   and valid_from_date = '2010-04-03';

-- incorrect detective_name updating

-- update crime_x_detective
-- set detective_name = 'Tom Bob'
-- where detective_name = 'Greg Lestrade'
--   and valid_from_date = '2010-04-03';

-- incorrect date to updating

-- update crime_x_detective
-- set valid_to_date = '01-01-1990'
-- where detective_name = 'Greg Lestrade'
--   and valid_from_date = '2010-04-03';

-- correct updating

update crime_x_detective
set valid_to_date = now()::date
where detective_name = 'Greg Lestrade'
  and valid_from_date = '2010-04-03';


-- Creating procedures (TASK 10)

-- procedure (1)
-- insertion of a new row into table 'Place of crime'

create or replace procedure insert_place_of_crime(place_id_p integer, place_name_p varchar(200), location_city_p varchar(200))
    language sql
as
$$
insert into place_of_crime
values (place_id_p, place_name_p, location_city_p);
$$;

-- test case
-- call insert_place_of_crime(8, 'Baker Street 221B', 'London');


-- procedure (2)
-- update organizer's motive

create or replace procedure update_organizer_motive(motive_id_p integer, motive_desc_p varchar(1000), motive_type_p varchar(200))
    language plpgsql
as
$$
begin
    update motive
    set
        motive_description = motive_desc_p,
        motive_type = motive_type_p
    where
        motive_id = motive_id_p;
end;
$$;

-- test case
call update_organizer_motive(6,
        'Criminal was intimidating Henry so that he could not restore the true events in his memory',
        'Hiding evidence')