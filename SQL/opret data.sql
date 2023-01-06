drop table if EXISTS movie_title CASCADE;
CREATE TABLE movie_title (
  tconst varchar PRIMARY key,
  title varchar not null,
  primarytitle text,
  originaltitle text,
  isadult bool,
  startyear varchar,
  endyear varchar,
  runtimeminutes int,
  genres text
);

drop table if EXISTS person CASCADE;
CREATE TABLE person (
  nconst varchar PRIMARY key,
  primaryname varchar not null,
  birthyear varchar,
  deathyear varchar,
  primaryprofession varchar,
	name_rating numeric
);

drop table if EXISTS movie_partof;
CREATE TABLE movie_partof (
  tconst varchar NOT NULL,
  ordering int not null,
  nconst varchar not null,
  category varchar,
  job text,
  characters text,
	PRIMARY key(tconst, nconst, ORDERING),
	FOREIGN key(tconst)
		REFERENCES movie_title(tconst),
	FOREIGN key(nconst)
		REFERENCES person(nconst)
);

drop table if EXISTS movie_akas;
CREATE TABLE movie_akas (
  titleid varchar not null,
  ordering int not null,
  title text,
  region varchar,
  language varchar,
  types varchar,
  attributes varchar,
  isoriginaltitle bool,
	PRIMARY key(titleid, ordering),
	FOREIGN key(titleid)
		REFERENCES movie_title(tconst)
);


drop table if EXISTS movie_rating;
CREATE TABLE movie_rating (
  tconst varchar not null,
  averagerating numeric,
  numvotes int,
	PRIMARY key(tconst),
	FOREIGN key(tconst)
		REFERENCES movie_title(tconst)
);

drop table if EXISTS movie_episode;
CREATE TABLE movie_episode (
  tconst varchar not null,
  parenttconst varchar,
  seasonnumber int,
  episodenumber int,
	PRIMARY key(tconst),
	FOREIGN key(tconst)
		REFERENCES movie_title(tconst),
	FOREIGN key(parenttconst)
		REFERENCES movie_title(tconst)
);

drop table if EXISTS OMDB_dataset;
CREATE TABLE OMDB_dataset (
  tconst varchar not null,
  poster text,
  plot text,
	PRIMARY key(tconst),
	FOREIGN key(tconst)
		REFERENCES movie_title(tconst)
);

-- her undersøger vi hvor meget af dataen fra title_crew som er redundent 
SELECT DISTINCT tconst, nconst from (select * from title_principals where category = 'director' or category = 'writer') temp3
where nconst not in 
(SELECT DISTINCT directors
from (SELECT tconst, UNNEST(STRING_TO_ARRAY(directors, ',')) AS directors FROM title_crew) temp1) 
and nconst not in 
(SELECT DISTINCT writers
from (SELECT tconst, UNNEST(STRING_TO_ARRAY(writers, ',')) AS writers FROM title_crew) temp1);
-- som man kan se fra resultatet så er der kun 39 fra crew som ikke opstår i principals derfor ser vi crew som redundent 


insert into movie_title(tconst, title, primarytitle, originaltitle, isadult, startyear, endyear, runtimeminutes, genres) SELECT * from title_basics;

insert into person(nconst, primaryname, birthyear, deathyear, primaryprofession) SELECT nconst, primaryname, birthyear, deathyear, primaryprofession from name_basics;

insert into movie_akas(titleid, ordering, title, region, language, types, attributes, isoriginaltitle) select * from title_akas; 

insert into movie_episode(tconst, parenttconst, seasonnumber, episodenumber) select * from title_episode;

insert into movie_rating(tconst, averagerating, numvotes) SELECT * from title_ratings;

insert into omdb_dataset(tconst, poster, plot) SELECT * from omdb_data;

insert into movie_partof(tconst, ordering, nconst, category, job, characters) SELECT * from title_principals where title_principals.nconst in (select name_basics.nconst from title_principals right join name_basics on title_principals.nconst = name_basics.nconst);


drop TABLE if EXISTS title_akas;
drop TABLE if EXISTS title_crew;
drop TABLE if EXISTS title_episode;
drop TABLE if EXISTS title_ratings;
drop TABLE if EXISTS name_basics;
drop TABLE if EXISTS title_principals;
drop TABLE if EXISTS title_basics;
drop TABLE if EXISTS omdb_data;

--e1
DROP INDEX IF EXISTS movie_title_index;
DROP INDEX IF EXISTS person_name_index;
CREATE INDEX movie_title_index ON movie_title (primarytitle);
CREATE INDEX person_name_index ON person (primaryname);