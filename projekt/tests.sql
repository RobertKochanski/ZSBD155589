-- CZYSZCZENIE DANYCH Z BAZY 
delete from project_game_categories;
delete from project_game_platforms;
delete from project_sales;
delete from project_games;
delete from project_categories;
delete from project_platforms;
delete from project_publishers;
delete from project_developers;
delete from project_games_stage;
delete from project_data_archive;
delete from project_load_logs;



select * from project_games_stage;

-- załadowanie danych i ich walidacja
begin
    project_load_games_etl;
end;
/

-- czy dane się załadowały
select game_id, title, release_date
from project_games;

-- czy platformy i kategorie wgrały się prawidłowo
select *
from project_platforms;

select *
from project_categories;

-- czy dane zostały zarchiwizowane
select *
from project_data_archive;

-- czy logi się zapisały
select * 
from project_load_logs
order by event_time;

-- czy dane sales zostały wgrane
select sale_id, region, units_sold, revenue, sale_year, g.title, g.release_date, g.rating
from project_sales s
join project_games g on s.game_id = g.game_id
order by g.title;
