// I
create table regions as (select * from hr.regions);
create table countries as (select * from hr.countries);
create table locations as (select * from hr.locations);
create table jobs as (select * from hr.jobs);
create table job_history as (select * from hr.job_history);
create table departments as (select * from hr.departments);
create table employees as (select * from hr.employees);
create table job_grades as (select * from hr.job_grades);
create table products as (select * from hr.products);
create table sales as (select * from hr.sales);

// II
alter table regions add primary key (region_id);
alter table countries add primary key (country_id);
alter table locations add primary key (location_id);
alter table jobs add primary key (job_id);
alter table job_history add primary key (employee_id, start_date);
alter table departments add primary key (department_id);
alter table employees add primary key (employee_id);
alter table job_grades add primary key (grade);
alter table products add primary key (product_id);
alter table sales add primary key (sale_id);

alter table countries add foreign key (region_id) references regions(region_id);
alter table locations add foreign key (country_id) references countries(country_id);
alter table departments add foreign key (location_id) references locations(location_id);
alter table departments add foreign key (manager_id) references employees(employee_id);
alter table job_history add foreign key (job_id) references jobs(job_id);
alter table job_history add foreign key (department_id) references departments(department_id);
alter table job_history add foreign key (employee_id) references employees(employee_id);
alter table employees add foreign key (job_id) references jobs(job_id);
alter table employees add foreign key (manager_id) references employees(employee_id);
alter table employees add foreign key (department_id) references departments(department_id);
alter table sales add foreign key (employee_id) references employees(employee_id);
alter table sales add foreign key (product_id) references products(product_id);

// III
// 1.
select last_name||' '||salary as wynagrodzenie
from employees
where (department_id = 20 or department_id = 50) and salary between 2000 and 7000
order by last_name;

// 2.
select * from employees;
select hire_date, last_name, salary
from employees
where hire_date between '05/01/01' and '05/12/31'
    and manager_id is not null
order by employees.salary;

// 3.
select (first_name||' '||last_name) as person, salary, phone_number 
from employees
where last_name like '__e%' 
    and first_name like '%ll%'
order by person desc, salary asc;

// 4.
select first_name, last_name, round(months_between(current_date, hire_date)) as work_months,
    case 
        when round(months_between(current_date, hire_date)) < 150
            then 0.1
        when round(months_between(current_date, hire_date)) < 200
            then 0.2
        else 0.3
    end * salary as wysokosc_dodatku
from employees
order by work_months;

// 5.
select jobs.job_title, jobs.min_salary, sum(employees.salary) as suma, round(avg(employees.salary), 0) as srednia
from employees
join jobs on jobs.job_id = employees.job_id
group by jobs.job_title, jobs.min_salary
having jobs.min_salary > 5000;

// 6.
select employees.last_name, departments.department_id, departments.department_name, employees.job_id
from employees
join departments on departments.department_id = employees.department_id
join locations on locations.location_id = departments.location_id
where locations.city = 'Toronto';

// 7.
select e.first_name, e.last_name, c.first_name, c.last_name
from employees e
join employees c 
    on e.department_id = c.department_id
where e.first_name = 'Jennifer' and e.employee_id != c.employee_id
order by e.last_name, c.last_name;

// 8.
select * 
from departments d
left join employees e on d.department_id = e.department_id
where e.employee_id is null;

// 9.
select e.first_name||' '||e.last_name as person, d.department_name, e.salary, jg.grade
from employees e
join departments d on e.department_id = d.department_id
join job_grades jg on e.salary between jg.min_salary and jg.max_salary;

// 10.
select first_name||' '||last_name as person, salary
from employees
where salary > (select avg(salary) from employees)
order by salary desc;

// 11.
select distinct employee_id, first_name, last_name
from employees
where department_id in (
    select distinct department_id
    from employees
    where lower(last_name) like '%u%'
);

// 12.
select *
from employees
where round(months_between(current_date, hire_date)) > 
    (select avg(round(months_between(current_date, hire_date))) from employees);

// 13.
select d.department_name, count(e.employee_id) as employee_number, round(avg(e.salary)) as avg_salary 
from departments d
left join employees e on d.department_id = e.department_id
group by d.department_name
order by employee_number desc;

