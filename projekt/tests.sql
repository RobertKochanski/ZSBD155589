-- CZYSZCZENIE DANYCH Z BAZY 
DELETE FROM project_game_categories;
DELETE FROM project_game_platforms;
DELETE FROM project_sales;
DELETE FROM project_games;
DELETE FROM project_categories;
DELETE FROM project_platforms;
DELETE FROM project_publishers;
DELETE FROM project_developers;
DELETE FROM project_games_stage;
DELETE FROM project_data_archive;
DELETE FROM project_load_logs;



select * from project_games_stage;

-- załadowanie danych i ich walidacja
begin
    project_load_games_etl;
end;
/

-- czy dane się załadowały
SELECT game_id, title, release_date
FROM project_games;

-- czy platformy i kategorie wgrały się prawidłowo
SELECT *
FROM project_platforms;

SELECT *
FROM project_categories;

-- czy dane zostały zarchiwizowane
SELECT *
FROM project_data_archive;

-- czy logi się zapisały
select * 
from project_load_logs
order by event_time;

-- czy dane sales zostały wgrane
select sale_id, region, units_sold, revenue, sale_year, g.title, g.release_date, g.rating
from project_sales s
join project_games g on s.game_id = g.game_id
order by g.title;
