-- CZYSZCZENIE DANYCH Z BAZY 
delete from project_sales_summary;
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
select * from project_games;
select * from project_sales;

select * from project_publishers;
select * from project_developers;

-- czy platformy/kategorie wgrały się prawidłowo
select * from project_platforms;
select * from project_categories;

-- czy dane zostały zarchiwizowane
select * from project_data_archive
order by archive_id desc;

-- czy logi się zapisały
select * from project_load_logs
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
--        p_developer_id => 47,
--        p_publisher_id => 42
--    );
    
    project_add_game(
        p_title        => 'Bad rating game',
        p_release_date => date '2024-05-10',
        p_rating       => 111,
        p_developer_id => 47,
        p_publisher_id => 42
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

-- czy sales_summary działa
-- roczne
begin
    project_build_sales_summary('YEAR', 2022);
end;
/

select period_year, sum(total_revenue)
from project_sales_summary
where period_type = 'YEAR'
group by period_year;

-- kwartalne
begin
    project_build_sales_summary('QUARTER', 2022);
end;
/

select period_value as quarter, sum(total_units)
from project_sales_summary
where period_type = 'QUARTER'
  and period_year = 2022
group by period_value
order by quarter;

-- miesięczne
begin
    project_build_sales_summary('MONTH', 2022);
end;
/

select period_value as month, sum(total_revenue)
from project_sales_summary
where period_type = 'MONTH'
  and period_year = 2022
group by period_value
order by month;

select period_value, period_type, period_year, sum(total_revenue) from project_sales_summary
where period_type='YEAR'
group by period_value, period_type, period_year;


-- miesięczne zestawienie z 2022 roku dla gry o id 30
begin
    project_build_sales_summary('MONTH', 2022, 30);
end;
/
select period_value, period_type, period_year, sum(total_revenue) from project_sales_summary
where period_type='MONTH' and game_id = 30
group by period_value, period_type, period_year;
