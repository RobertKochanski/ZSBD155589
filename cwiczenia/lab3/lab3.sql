// 1.
create view v_wysokie_pensje as
    select *
    from employees
    where salary > 6000;


// 2. 
create or replace view v_wysokie_pensje as
    select *
    from employees
    where salary > 12000;
    
// 3.
drop view v_wysokie_pensje;

// 4.
create view v_finance_employees as
    select e.employee_id, e.last_name, e.first_name
    from employees e
        join departments d on d.department_id = e.department_id
    where d.department_name = 'Finance';
    
// 5.
create view v_salary_5000_12000 as
    select employee_id, last_name, first_name, salary, job_id, email, hire_date
    from employees
    where salary between 5000 and 12000;
    
// 6. zmiany na widokach powoduja zmiany na tabelach
// a.
// do v_finance_employees nie można dodać rekordu ponieważ nie ma pokrycia w wymaganych kolumnach
// tabel na bazie których powstał widok
insert into v_finance_employees values (207, 'Andrzej', 'Kowalski');

// w v_salary_5000_12000 można dodać rekord ponieważ posiada w sobie wymagane kolumny
// należy jednak uważać na kolejność kolumn która różni się od tabeli bazowej
insert into v_salary_5000_12000
values (207, 'Andrzej', 'Kowalski', 9999, 'FI_ACCOUNT', 'AKowalski', DATE '2020-07-01');

// b.
update v_salary_5000_12000
set last_name = 'Kowalski',
    first_name = 'Andrzej'
where employee_id = 207;

// c.
delete from v_salary_5000_12000
where employee_id = 207;

// 7.
create view v_atleast_4_employees as
    select d.department_id, d.department_name, count(e.employee_id) as emp_number, round(avg(e.salary)) as avg_salary, max(e.salary) as max_salary
    from departments d
        join employees e on d.department_id = e.department_id
    group by d.department_id, d.department_name
    having count(e.employee_id) > 4;
    
// a.
// "nie można modyfikować kolumny, która odwzorowuje się do tabeli nie zachowującej kluczy"
insert into v_atleast_4_employees
values (100, 'Finance', 123, 9999, 12121);

// 8.
create view v_salary_5000_12000_with_check as
    select employee_id, last_name, first_name, salary, job_id, email, hire_date
    from employees
    where salary between 5000 and 12000
with check option;

// a1.
insert into v_salary_5000_12000_with_check
values (209, 'Andrzej', 'Kowalski', 9999, 'FI_ACCOUNT', 'AKowalski', DATE '2020-07-01');

// a2.
// "naruszenie klauzuli WHERE dla perspektywy z WITH CHECK OPTION"
insert into v_salary_5000_12000_with_check
values (208, 'Andrzej', 'Kowalski', 20000, 'FI_ACCOUNT', 'AKowalski', DATE '2020-07-01');

// 9.
create materialized view v_managerowie
build immediate
refresh complete on commit
as
    select e.first_name || ' ' || e.last_name as manager, d.department_name
    from employees e
        join departments d on e.department_id = d.department_id
    where d.manager_id = e.employee_id;
    
// 10.
create view v_najlepiej_oplacani as
    select * 
    from employees
    order by salary desc
    fetch first 10 row only;
