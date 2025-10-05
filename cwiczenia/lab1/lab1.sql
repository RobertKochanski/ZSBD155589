//1
CREATE TABLE Regions (
region_id int,
region_name varchar(50),
primary key (region_id)
);

create table Countries (
country_id int primary key,
country_name varchar(50),
region_id int,
FOREIGN KEY (region_id) REFERENCES Regions(region_id)
);

create table Locations (
location_id int primary key,
street_address varchar(50),
postal_code varchar(6),
state_province varchar(50),
country_id int,
FOREIGN KEY (country_id) REFERENCES Countries(country_id)
);

create table Jobs (
job_id int primary key,
job_title varchar(100),
min_salary number,
max_salary number
);

create table Employees(
employee_id int primary key,
first_name varchar(20),
last_name varchar(30),
email varchar(30),
phone_number varchar(11),
hire_date date,
job_id int,
salary number,
commission_pct number,
manager_id int,
department_id int,
foreign key (job_id) references Jobs(job_id) on delete set null,
foreign key (manager_id) references Employees(employee_id)
);

create table Departments (
department_id int primary key,
department_name varchar(50),
manager_id int,
location_id int,
foreign key (location_id) references Locations(location_id)
);

create table Job_History (
employee_id int,
start_date date,
end_date date,
job_id int,
department_id int
);

ALTER TABLE Job_History
ADD CONSTRAINT PK_Job_History PRIMARY KEY (employee_id, start_date);

alter table Job_History
add foreign key (employee_id) references Employees(employee_id);

alter table Job_History
add foreign key (job_id) references Jobs(job_id);

alter table Job_History
add foreign key (department_id) references Departments(department_id);

alter table Locations
add city varchar(50);

alter table Employees
add foreign key (department_id) references Departments(department_id);

alter table Departments
add foreign key (manager_id) references Employees(employee_id);

alter table Employees
add constraint fk_emp_job
foreign key (job_id)
references jobs(job_id)
on delete set null;

alter table Job_History
add constraint fk_emp_job_his
foreign key (job_id)
references jobs(job_id)
on delete set null;

alter table Jobs
add check (min_salary < max_salary - 2000);

//2
insert all
    into Jobs (job_id, job_title, min_salary, max_salary) values (1, 'a', 1000, 4500)
    into Jobs (job_id, job_title, min_salary, max_salary) values (2, 'b', 5000, 10000)
    into Jobs (job_id, job_title, min_salary, max_salary) values (3, 'c', 2000, 4321.99)
    into Jobs (job_id, job_title, min_salary, max_salary) values (4, 'test', 12345, 54321)
select 1 from dual;

//3
insert all
    into Employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct) 
    values (1, 'Jan', 'Nowak', 'jan.nowak@email.com', 123456789, DATE '2025-01-01', 3, 4000, 0.05)
    into Employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct) 
    values (2, 'Andrzej', 'Kowalski', 'andrzej.kowalski@email.com', +48123123123, DATE '2020-07-01', 4, 10000, 0.1)
    into Employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct) 
    values (3, 'Robert', 'Kubica', 'robert.kubica@email.com', 321456987, DATE '2022-12-12', 2, 7000, 0.07)
    into Employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct) 
    values (4, 'Jan', 'Pawel', 'jan.pawel@email.com', 123123123, DATE '2025-06-01', 1, 4000, 0)
select 1 from dual;

//4
update Employees
set manager_id = 1
where employee_id = 2 or employee_id = 3;

//5
update Jobs
set max_salary = max_salary + 500, min_salary = min_salary + 500
where job_title like '%b%' or job_title like '%s%';

//6
delete from Jobs
where max_salary > 9000;

//7
drop table Jobs cascade constraints;
show recyclebin;
flashback table Jobs to before drop;

//helper
select * from Employees;
select * from Jobs;