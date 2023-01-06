drop table if EXISTS users CASCADE;
CREATE TABLE users (
  userid varchar PRIMARY key,
  password varchar not null,
	salt VARCHAR,
	admin bool not null
);

drop table if EXISTS search_history;
CREATE TABLE search_history (
	userid VARCHAR not null,
	searchword varchar,
	sh_timestamp TIMESTAMP,
	PRIMARY key(userid, searchword, sh_timestamp),
	FOREIGN key(userid)
		REFERENCES users(userid) ON DELETE CASCADE
);

drop table if EXISTS user_rating;
CREATE TABLE user_rating (
	userid VARCHAR not null,
	tconst varchar not null,
	rating int,
	PRIMARY key(userid, tconst, rating),
	FOREIGN key(userid)
		REFERENCES users(userid),
	FOREIGN key(tconst)
		REFERENCES movie_title(tconst)
);

drop table if EXISTS user_bookmark_title;
CREATE TABLE user_bookmark_title (
	userid VARCHAR not null,
	tconst varchar not null,
	PRIMARY key(userid, tconst),
	FOREIGN key(userid)
		REFERENCES users(userid),
	FOREIGN key(tconst)
		REFERENCES movie_title(tconst)
);

drop table if EXISTS user_bookmark_name;
CREATE TABLE user_bookmark_name (
	userid VARCHAR not null,
	nconst varchar not null,
	PRIMARY key(userid, nconst),
	FOREIGN key(userid)
		REFERENCES users(userid),
	FOREIGN key(nconst)
		REFERENCES person(nconst)
);

drop table if EXISTS title_search;
CREATE TABLE title_search (
	userid VARCHAR not null,
	tconst varchar not null,
	ts_timestamp TIMESTAMP,
	PRIMARY key(userid, tconst),
	FOREIGN key(userid)
		REFERENCES users(userid),
	FOREIGN key(tconst)
		REFERENCES movie_title(tconst)
);

drop table if EXISTS name_search;
CREATE TABLE name_search (
	userid VARCHAR not null,
	nconst varchar not null,
	ts_timestamp TIMESTAMP,
	PRIMARY key(userid, nconst),
	FOREIGN key(userid)
		REFERENCES users(userid),
	FOREIGN key(nconst)
		REFERENCES person(nconst)
);


drop table if EXISTS movie_clicks;
CREATE TABLE movie_clicks (
	tconst VARCHAR not null,
	amount int,
	PRIMARY key(tconst),
	FOREIGN key(tconst)
		REFERENCES movie_title(tconst)
);