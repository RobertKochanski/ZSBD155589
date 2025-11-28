// 1, 2
declare
    numer_max departments.department_id%type;
    dep_name departments.department_name%type := 'EDUCATION';
begin
    select max(department_id) into numer_max from departments;
    insert into departments values (numer_max + 10, dep_name, null, null);
    update departments set location_id = 3000 where department_id = numer_max + 10;
end;
/

// 3
create table nowa(numbers varchar(5));

declare
    liczba number:= 0;
begin
    while liczba < 10 
    loop
        liczba := liczba + 1;
        if liczba != 4 and liczba != 6 then
            insert into nowa values (liczba);
        end if;
    end loop;
end;
/

// 4
declare
    v_country countries%rowtype;
begin
    select *
    into v_country
    from countries
    where country_id = 'CA';

    dbms_output.put_line('Country name: ' || v_country.country_name);
    dbms_output.put_line('Region ID: ' || v_country.region_id);
end;
/

// 5
declare
    v_job   jobs%rowtype;
    v_count number := 0;
begin
    update jobs
    set min_salary = min_salary * 1.05
    where job_title like '%Manager%';

    v_count := sql%rowcount;

    dbms_output.put_line('Zaktualizowano rekordów: ' || v_count);

    rollback;
end;
/

// 6
declare
    v_job jobs%rowtype;
begin
    select *
    into v_job
    from (
        select *
        from jobs
        order by max_salary desc
    )
    where rownum = 1;

    dbms_output.put_line('Job ID: ' || v_job.job_id);
    dbms_output.put_line('Title: ' || v_job.job_title);
    dbms_output.put_line('Max salary: ' || v_job.max_salary);
end;
/

// 7
declare
    cursor c_kraje (p_region_id number) is
        select c.country_id,
               c.country_name,
              (select count(*) 
               from employees e
               join departments d on e.department_id = d.department_id
               join locations l on d.location_id = l.location_id
               where l.country_id = c.country_id
              ) as liczba_pracownikow
        from countries c
        where c.region_id = p_region_id;

    v_country_id        countries.country_id%type;
    v_country_name      countries.country_name%type;
    v_liczba_prac       number;
begin
    open c_kraje(1);

    loop
        fetch c_kraje into v_country_id, v_country_name, v_liczba_prac;
        exit when c_kraje%notfound;

        dbms_output.put_line(
            'Kraj: ' || v_country_name ||
            ' (' || v_country_id || ') -> Pracowników: ' || v_liczba_prac
        );
    end loop;

    close c_kraje;
end;
/

// 8
DECLARE
    CURSOR c_prac IS
        SELECT last_name, salary
        FROM employees
        WHERE department_id = 50;

    v_last_name employees.last_name%TYPE;
    v_salary    employees.salary%TYPE;
BEGIN
    OPEN c_prac;
    LOOP
        FETCH c_prac INTO v_last_name, v_salary;
        EXIT WHEN c_prac%NOTFOUND;

        IF v_salary > 3100 THEN
            dbms_output.put_line(v_last_name || ' - nie dawać podwyżki');
        ELSE
            dbms_output.put_line(v_last_name || ' - dać podwyżkę');
        END IF;
    END LOOP;

    CLOSE c_prac;
END;
/

// 9
declare
    cursor c_prac
        (p_min_salary employees.salary%type,
         p_max_salary employees.salary%type,
         p_name_part varchar2) 
    is
        select salary, first_name, last_name
        from employees
        where salary between p_min_salary and p_max_salary
          and upper(first_name) like '%' || upper(p_name_part) || '%';

    v_salary employees.salary%type;
    v_fname  employees.first_name%type;
    v_lname  employees.last_name%type;

begin
    dbms_output.put_line('--- Pracownicy 1000–5000 z literą A ---');

// a
    open c_prac(1000, 5000, 'a');
    loop
        fetch c_prac into v_salary, v_fname, v_lname;
        exit when c_prac%notfound;

        dbms_output.put_line(v_fname || ' ' || v_lname || ' - ' || v_salary);
    end loop;
    close c_prac;

    dbms_output.put_line('--- Pracownicy 5000–20000 z literą U ---');

// b
    open c_prac(5000, 20000, 'u');
    loop
        fetch c_prac into v_salary, v_fname, v_lname;
        exit when c_prac%notfound;

        dbms_output.put_line(v_fname || ' ' || v_lname || ' - ' || v_salary);
    end loop;
    close c_prac;

end;
/

// 10
CREATE TABLE statystyki_menedzerow (
    manager_id NUMBER,
    liczba_podwladnych NUMBER,
    roznica_plac NUMBER
);

declare
begin
    insert into statystyki_menedzerow (manager_id, liczba_podwladnych, roznica_plac)
    select 
        manager_id,
        count(*),
        max(salary) - min(salary)
    from employees
    where manager_id is not null
    group by manager_id;

    dbms_output.put_line('Dane zostały zapisane do STATYSTYKI_MENEDZEROW.');
end;
/