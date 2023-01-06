--d1
DEALLOCATE all; -- fjerner alle prep statments 
PREPARE signup(text, text) as 
SELECT user_signup($1,$2, $3);
EXECUTE signup('mads', '1234', true);

PREPARE login(text, text) as 
SELECT login_user($1,$2);
EXECUTE login('mads', '1234');

select create_name_bookmark('mads', 'nm0037476');
select nconst from user_bookmark_name where userid = 'mads' and nconst = 'nm0037476';
SELECT delete_name_bookmark('mads', 'nm0037476');
select nconst from user_bookmark_name where userid = 'mads' and nconst = 'nm0037476';

select create_title_bookmark('mads', 'tt7856872');
select tconst from user_bookmark_title where userid = 'mads' and tconst = 'tt7856872';
SELECT delete_title_bookmark('mads', 'tt7856872');
select tconst from user_bookmark_title where userid = 'mads' and tconst = 'tt7856872';

select movie_visited('tt7856872');
select amount from movie_clicks where tconst = 'tt7856872';
select movie_visited('tt7856872');
select amount from movie_clicks where tconst = 'tt7856872';

PREPARE temp(text, text) as 
SELECT search_word($1,$2);
EXECUTE temp('mads', 'apocaliops');
SELECT searchword from search_history where userid = 'mads';
SELECT delete_search('mads');
SELECT searchword from search_history where userid = 'mads';

select search_title('mads', 'tt7856872');
select tconst from title_search where userid = 'mads';
select delete_search_title('mads');
select tconst from title_search where userid = 'mads';

select search_name('mads', 'nm0037476');
select nconst from name_search where userid = 'mads';
select delete_search_name('mads');
select nconst from name_search where userid = 'mads';

select * from string_search('war');

--d2
PREPARE string_search_pr(text, text) as
SELECT * from string_search($1, $2);
EXECUTE string_search_pr('war', 'mads');
SELECT searchword from search_history where userid = 'mads';
SELECT delete_search('mads');
SELECT searchword from search_history where userid = 'mads';


--d3
select averagerating, numvotes from movie_rating where tconst = 'tt21212430';
select create_rating('mads', 'tt21212430', 1);
select averagerating, numvotes from movie_rating where tconst = 'tt21212430';
select rating from user_rating where userid = 'mads' and tconst = 'tt21212430';
select delete_rating('mads', 'tt21212430');
select rating from user_rating where userid = 'mads' and tconst = 'tt21212430';
select averagerating, numvotes from movie_rating where tconst = 'tt21212430';


-- d4
SELECT * from structured_string_search_part('ring', 'mads');
SELECT * from structured_string_search('war', 'nemo', 'friends','ring', 'mads');

--d5
SELECT * from structured_string_search_part_name('ring', 'mads');
SELECT * from structured_string_search_name('war', 'nemo', 'friends','ring', 'mads');

--d6
SELECT * from find_coplayers('Mads Mikkelsen');
SELECT * from find_coplayers('Thomas Vinterberg');

--d7 
SELECT name_rating_setter();

--d8
select * from movie_actors_by_rating('tt2178784');

--d9
select * from similar_movies('tt2178784');

--d10
SELECT * from person_words('Mads Mikkelsen');

--d11
select * from exact_match('world');
select * from exact_match('worl');
select * from exact_match('mads','world');
select * from exact_match('mads','worl');
SELECT * from exact_match('world', 'mads', 'apples', 'adam');


--d12
SELECT * from best_match('mads');
SELECT * from best_match('world', 'mads');
SELECT * from best_match('worl', 'mads');
SELECT * from best_match('world', 'mads', 'thomas', 'sisse', 'adam');


--d13
SELECT * from word_word_match('world');
SELECT * from word_word_match('world', 'mads');


SELECT delete_user('mads');
SELECT * from login_user('mads', '1234');