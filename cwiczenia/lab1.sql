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
foreign key (job_id) references Jobs(job_id),
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

alter table Jobs
add check (min_salary < max_salary - 2000);