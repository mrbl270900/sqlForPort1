--d1
-- funktion til at oprette et bogmærke på et navn
CREATE OR REPLACE FUNCTION create_name_bookmark(userid_input varchar(60), nconst_input varchar(20))
 returns void as $$
begin
insert into user_bookmark_name(userid, nconst) VALUES (userid_input, nconst_input); 
end;
$$ LANGUAGE plpgsql;
-- funktion til at fjerne et bogmærke på et navn
CREATE OR REPLACE FUNCTION delete_name_bookmark(userid_input varchar(60), nconst_input varchar(20))
 returns void as $$
begin
DELETE from user_bookmark_name where userid = userid_input and nconst = nconst_input; 
end;
$$ LANGUAGE plpgsql;

-- funktion til at oprette et bogmærke på en titel
CREATE OR REPLACE FUNCTION create_title_bookmark(userid_input varchar(60), tconst_input varchar(20))
 returns void as $$
begin
insert into user_bookmark_title(userid, tconst) VALUES (userid_input, tconst_input); 
end;
$$ LANGUAGE plpgsql;
-- funktion til at slette et bogmærke på en titel
CREATE OR REPLACE FUNCTION delete_title_bookmark(userid_input varchar(60), tconst_input varchar(20))
 returns void as $$
begin
DELETE from user_bookmark_title where userid = userid_input and tconst = tconst_input; 
end;
$$ LANGUAGE plpgsql;

--funktion til at oprette en bruger i systemet ud fra brugerid og kodeord
CREATE OR REPLACE FUNCTION user_signup(userid_input varchar(60), password_input varchar(60), admin_input bool)
 returns void as $$
begin
insert into users(userid, password, admin) VALUES (userid_input, password_input, admin_input);
end;
$$ LANGUAGE plpgsql;
--funktion til at slette en bruger i systemet ud fra brugerid
CREATE OR REPLACE FUNCTION delete_user(userid_input varchar(60))
 returns void as $$
begin
DELETE from users where userid = userid_input;
end;
$$ LANGUAGE plpgsql;

-- funktion til at se om et brugerid passer med et kodeord der retunere sandt eller falsk
CREATE OR REPLACE FUNCTION login_user(userid_input varchar(60), password_input varchar(20))
 returns bool as $$
begin
if EXISTS
(SELECT * from users where users.userid = userid_input and users.password = password_input)
then return TRUE;
else return FALSE;
end if;
end;
$$ LANGUAGE plpgsql;

--funktion til at opdatere mængden af personer der har clikket på en titel
CREATE OR REPLACE FUNCTION movie_visited(tconst_input varchar(20))
 returns void as $$
begin
if not EXISTS (SELECT tconst from movie_clicks where tconst = tconst_input) then 
insert into movie_clicks(tconst, amount) VALUES (tconst_input, 1); 
else update movie_clicks set amount = amount + 1 where tconst = tconst_input; 
end if;
end;
$$ LANGUAGE plpgsql;

--en funktion til at logge hvad en bruger har søgt på
CREATE OR REPLACE FUNCTION search_word(userid_input varchar(60), search_word varchar(240))
 returns void as $$
 begin
insert into search_history(userid, searchword, sh_timestamp) VALUES (userid_input, search_word, CURRENT_TIMESTAMP);
end;
$$ LANGUAGE plpgsql;
-- funktion til at en bruger kan slette deres søge historik
CREATE OR REPLACE FUNCTION delete_search(userid_input varchar(60))
 returns void as $$
begin
DELETE from search_history where userid = userid_input; 
end;
$$ LANGUAGE plpgsql;

-- funktion til at logge hvilke titler en bruger har trykket på
CREATE OR REPLACE FUNCTION search_title(userid_input varchar(60), tconst_input varchar(20))
 returns void as $$
 begin
insert into title_search(userid, tconst, ts_timestamp) VALUES (userid_input, tconst_input, CURRENT_TIMESTAMP);
end;
$$ LANGUAGE plpgsql;
-- funktion til at slette en brugers title tryk historik
CREATE OR REPLACE FUNCTION delete_search_title(userid_input varchar(60))
 returns void as $$
begin
DELETE from title_search where userid = userid_input; 
end;
$$ LANGUAGE plpgsql;
--samme som over bare med navne 
CREATE OR REPLACE FUNCTION search_name(userid_input varchar(60), nconst_input varchar(20))
 returns void as $$
 begin
insert into name_search(userid, nconst, ts_timestamp) VALUES (userid_input, nconst_input, CURRENT_TIMESTAMP);
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_search_name(userid_input varchar(60))
 returns void as $$
begin
DELETE from name_search where userid = userid_input; 
end;
$$ LANGUAGE plpgsql;

--d2
-- funktion til at søge efter en string i plot eller i title af film 
CREATE OR REPLACE FUNCTION string_search(user_input varchar(240))
 returns table(tconst varchar, title text) as $$
begin
return query
select movie_title.tconst, movie_title.primarytitle from movie_title NATURAL join omdb_data where movie_title.primarytitle like '%' || user_input || '%' or omdb_data.plot like '%' || user_input || '%';
end;
$$ LANGUAGE plpgsql;

-- samme som over bare hvor input logges til et brugerid
CREATE OR REPLACE FUNCTION string_search(user_input varchar(240), userid_input varchar(60))
 returns table(tconst varchar, title text) as $$
begin
PERFORM search_word(userid_input, user_input);
return query
select movie_title.tconst, movie_title.primarytitle from movie_title NATURAL join omdb_data where movie_title.primarytitle like '%' || user_input || '%' or omdb_data.plot like '%' || user_input || '%'; 
end;
$$ LANGUAGE plpgsql;

--d3
--funktion til at oprette en rating på en titel
CREATE OR REPLACE FUNCTION create_rating(userid_input varchar(60), tconst_input varchar(20), rating_input int)
 returns void as $$
begin
insert into user_rating(userid, tconst, rating) VALUES (userid_input, tconst_input, rating_input); 
update movie_rating 
set numvotes = numvotes + 1, averagerating = round(((averagerating * numvotes) + rating_input)/(numvotes + 1), 2)
where tconst_input = movie_rating.tconst;
end;
$$ LANGUAGE plpgsql;

--funktion til at slette en rating på en titel
CREATE OR REPLACE FUNCTION delete_rating(userid_input varchar(60), tconst_input varchar(20))
 returns void as $$
begin
update movie_rating 
set numvotes = numvotes - 1, averagerating = round((averagerating * numvotes - (SELECT user_rating.rating from user_rating where user_rating.userid = userid_input and user_rating.tconst = tconst_input))/(numvotes - 1), 2)
where tconst_input = movie_rating.tconst;
DELETE from user_rating where userid = userid_input and tconst = tconst_input; 
end;
$$ LANGUAGE plpgsql;


--d4
-- funktion til at søge efter 4 strings
CREATE OR REPLACE FUNCTION structured_string_search_part(user_input varchar(240), userid_input varchar(60))
 returns table(tconst varchar, title text) as $$
begin
PERFORM search_word(userid_input, user_input);
return query
select movie_title.tconst, movie_title.primarytitle 
from movie_title NATURAL join omdb_dataset NATURAL join movie_partof NATURAL join person 
where movie_title.primarytitle like '%' || user_input || '%' or omdb_dataset.plot like '%' || user_input || '%' or movie_partof.characters like '%' || user_input || '%' or person.primaryname like '%' || user_input || '%'; 
end;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION structured_string_search(title_input varchar(240), plot_input varchar(240), characters_input varchar(240), persons_input varchar(240), userid_input varchar(60))
 returns table(tconst varchar, title text) as $$
begin
return query
SELECT * from structured_string_search_part(title_input, userid_input) union SELECT * from structured_string_search_part(plot_input, userid_input) union SELECT * from structured_string_search_part(characters_input, userid_input) union SELECT * from structured_string_search_part(persons_input, userid_input);
end;
$$ LANGUAGE plpgsql;


--d5
CREATE OR REPLACE FUNCTION structured_string_search_part_name(user_input varchar(240),  userid_input varchar(60))
 returns table(nconst varchar, name varchar) as $$
begin
PERFORM search_word(userid_input, user_input);
return query
select person.nconst, person.primaryname 
from movie_title NATURAL join omdb_dataset NATURAL join movie_partof NATURAL join person 
where movie_title.primarytitle like '%' || user_input || '%' or omdb_dataset.plot like '%' || user_input || '%' or movie_partof.characters like '%' || user_input || '%' or person.primaryname like '%' || user_input || '%'; 
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION structured_string_search_name(title_input varchar(240), plot_input varchar(240), characters_input varchar(240), persons_input varchar(240), userid_input varchar(60))
 returns table(nconst varchar, name varchar) as $$
begin
return query
SELECT * from structured_string_search_part_name(title_input, userid_input) union SELECT * from structured_string_search_part_name(plot_input, userid_input) union SELECT * from structured_string_search_part_name(characters_input, userid_input) union SELECT * from structured_string_search_part_name(persons_input, userid_input);
end;
$$ LANGUAGE plpgsql;

--d6
CREATE OR REPLACE FUNCTION find_coplayers(name_input varchar(60))
 returns table(nconst varchar, name varchar, frequency bigint) as $$
begin
return query
SELECT movie_partof.nconst, primaryname, count(movie_partof.nconst) 
from movie_partof NATURAL join person 
where movie_partof.nconst in (select movie_partof.nconst from movie_partof where movie_partof.tconst in (SELECT movie_partof.tconst from movie_partof NATURAL join person where person.primaryname = name_input)) 
and movie_partof.tconst in (SELECT movie_partof.tconst from movie_partof NATURAL join person where person.primaryname = name_input) 
and person.primaryname not like name_input 
GROUP BY movie_partof.nconst, primaryname order by count DESC;
end;
$$ LANGUAGE plpgsql;

--d7 
CREATE OR REPLACE FUNCTION name_rating_setter()
 returns void as $$
begin
update person 
set name_rating = c1 from
(SELECT movie_partof.nconst, round(sum(temp.wavg)/sum(movie_rating.numvotes), 2) as c1 
from (SELECT movie_partof.nconst, movie_rating.averagerating * movie_rating.numvotes as wavg
from movie_partof NATURAL join movie_rating 
where movie_partof.nconst like movie_partof.nconst) temp, 
movie_rating NATURAL join movie_partof where movie_partof.nconst = temp.nconst
GROUP BY movie_partof.nconst) temp 
where person.nconst = temp.nconst;
end;
$$ LANGUAGE plpgsql;


-- d8
CREATE OR REPLACE FUNCTION movie_actors_by_rating(tconst_input varchar(60))
 returns table(nconst varchar, primaryname varchar, name_rating numeric) as $$
begin
return query
select person.nconst, person.primaryname, person.name_rating from person NATURAL join movie_partof where movie_partof.tconst = tconst_input ORDER BY name_rating DESC;
end;
$$ LANGUAGE plpgsql;

--d9
CREATE OR REPLACE FUNCTION similar_movies(tconst_input varchar(60))
 returns table(nconst varchar, primaryname text, movie_rating NUMERIC) as $$
begin
return query
select DISTINCT movie_title.tconst, movie_title.primarytitle, movie_rating.averagerating 
from movie_title NATURAL join movie_partof NATURAL join movie_rating
where movie_title.tconst in (SELECT movie_title.tconst from movie_title NATURAL join (SELECT tconst, UNNEST(STRING_TO_ARRAY(movie_title.genres, ',')) gen from movie_title) temp where gen in (SELECT UNNEST(STRING_TO_ARRAY(movie_title.genres, ',')) from movie_title where tconst = tconst_input))
and movie_rating.numvotes > 100 
and movie_partof.nconst like any (select movie_partof.nconst from movie_partof where tconst = tconst_input) 
and tconst not like tconst_input
order by movie_rating.averagerating DESC LIMIT 10;
end;
$$ LANGUAGE plpgsql; 

--d10
CREATE OR REPLACE FUNCTION person_words(name_input varchar(60))
 returns table(nconst text) as $$
begin
return query
SELECT count || ' ' || word as "WI" from (select count(wi.word)::VARCHAR(10), wi.word 
from person NATURAL join movie_partof NATURAL join wi 
where person.primaryname = name_input 
GROUP BY wi.word order by count desc limit 10) temp;
end;
$$ LANGUAGE plpgsql;

--d11
CREATE or replace FUNCTION exact_match(VARIADIC w text[])
returns table(tconst char(30)) as $$
DECLARE
w_elem text;
t text := 'select DISTINCT wi.tconst from wi where tconst in ';
x int;
BEGIN
FOREACH w_elem IN ARRAY w
LOOP
t := t || '(SELECT wi.tconst from wi where wi.word = ''';
t := t || w_elem;
t := t || ''') and tconst in';
END LOOP;
t := t || '(select wi.tconst from wi)';
RETURN QUERY EXECUTE t;
END $$
LANGUAGE plpgsql;


--d12
CREATE or replace FUNCTION best_match(VARIADIC w text[])
returns table(tconst char(30), weight bigint) as $$
DECLARE
w_elem text;
t text := 'select wi.tconst, count(wi.tconst) as weight from wi where ';
BEGIN
FOREACH w_elem IN ARRAY w
LOOP
t := t || 'wi.word = ''';
t := t || w_elem;
t := t || ''' or ';
END LOOP;
t := t || 'wi.tconst = null GROUP BY wi.tconst ORDER BY weight desc;';
RETURN QUERY EXECUTE t;
END $$
LANGUAGE plpgsql;

--d13
CREATE or replace FUNCTION word_word_match(VARIADIC w text[])
returns table(weight bigint, word text) as $$
DECLARE
w_elem text;
t text := 'SELECT count(wi.word) as weight, wi.word from wi where tconst in (select tconst from wi where ';
BEGIN
FOREACH w_elem IN ARRAY w
LOOP
t := t || 'wi.word = ''';
t := t || w_elem;
t := t || ''' or ';
END LOOP;
t := t || 'wi.tconst = null) GROUP BY wi.word ORDER BY weight desc;';
RETURN QUERY EXECUTE t;
END $$
LANGUAGE plpgsql;
