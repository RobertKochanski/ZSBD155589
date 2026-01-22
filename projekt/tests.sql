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
select *
from project_games;

-- czy platformy/kategorie wgrały się prawidłowo
select *
from project_platforms;

select *
from project_categories;

-- czy dane zostały zarchiwizowane
select *
from project_data_archive
order by archive_id desc;

-- czy logi się zapisały
select * 
from project_load_logs
order by log_id desc;

-- czy dane sales zostały wgrane
select sale_id, region, units_sold, revenue, sale_year, g.title, g.release_date, g.rating
from project_sales s
join project_games g on s.game_id = g.game_id
order by g.title;


-- czy procedura dodawania gry działa
begin
--    project_add_game(
--        p_title        => 'Test Game 1',
--        p_release_date => date '2024-05-10',
--        p_rating       => 85,
--        p_developer_id => 5,
--        p_publisher_id => 5
--    );
    
    project_add_game(
        p_title        => 'Bad rating game',
        p_release_date => date '2024-05-10',
        p_rating       => 111,
        p_developer_id => 5,
        p_publisher_id => 5
    );
end;
/

-- czy procedura zmiany ratingu gry działa
begin
    project_update_game_rating(
        p_game_id       => 6,
        p_new_rating    => 94
    );
end;
/

-- czy procedura usuwania gry działa
begin
    project_delete_game(
        p_game_id   => 10
    );
end;
/