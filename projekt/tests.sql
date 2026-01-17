-- wyczyść dane z tabeli i wgraj je z pliku .csv do project_games_stage
TRUNCATE TABLE project_games_stage;

select * from project_games_stage;

-- załadowanie danych i ich walidacja
begin
    project_load_games_etl;
end;
/

-- czy dane się załadowały
SELECT game_id, title, release_date
FROM project_games;

-- czy zduplikowane dane wgrały się prawidłowo (były 2x wiedźminy w pliku)
SELECT title, release_date, COUNT(*)
FROM project_games
GROUP BY title, release_date;

-- czy platformy i kategorie wgrały się prawidłowo
SELECT g.title, p.name AS platform
FROM project_games g
JOIN project_game_platforms gp ON g.game_id = gp.game_id
JOIN project_platforms p ON gp.platform_id = p.platform_id;

SELECT g.title, c.name AS platform
FROM project_games g
JOIN project_game_categories gc ON g.game_id = gc.game_id
JOIN project_categories c ON gc.category_id = c.category_id;

-- czy dane zostały zarchiwizowane
SELECT *
FROM project_data_archive;

-- czy logi się zapisały
select * 
from project_load_logs
order by event_time;
