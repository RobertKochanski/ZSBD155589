// 1
create or replace procedure add_row_to_jobs(j_id in jobs.job_id%type, j_title in jobs.job_title%type) is
begin
    insert into jobs (job_id, job_title) values (j_id, j_title);
    
exception
    when dup_val_on_index then
    dbms_output.put_line('Duplicated value');
    when others then
    dbms_output.put_line('Something went wrong');
end;
/

begin
    add_row_to_jobs(20, 'test');
end;
/

// 2
create or replace procedure update_row_in_jobs(j_id in jobs.job_id%type, j_title in jobs.job_title%type) is
begin
    update jobs set job_title = j_title
    where job_id = j_id;
    
    if sql%notfound then
        raise case_not_found;
    end if;
    
    exception
    when rowtype_mismatch then
    dbms_output.put_line('Mismatched types');
    when case_not_found then
    dbms_output.put_line('Job not found');
    when others then
    dbms_output.put_line('Something went wrong');
end;
/

begin
    update_row_in_jobs(20, 'test change');
end;
/

// 3
create or replace procedure delete_job_by_id(p_job_id in jobs.job_id%type) is
begin
    delete from jobs
    where job_id = p_job_id;
    if sql%notfound then
        raise case_not_found;
    end if;
    
    dbms_output.put_line('Job deleted');
    
    exception
    when case_not_found then
    dbms_output.put_line('Job not found');
end;
/

begin
    delete_job_by_id(20);
end;
/

// 4
create or replace procedure get_employee_by_id(p_employee_id in employees.employee_id%type) is
    v_last_name employees.last_name%type;
    v_salary employees.salary%type;
begin
    select last_name, salary into v_last_name, v_salary
    from employees
    where employee_id = p_employee_id;
    
    if sql%notfound then
        raise case_not_found;
    end if;
    
    dbms_output.put_line('Employee: ' || v_last_name || ', Salary: ' || v_salary);
    
    exception
    when case_not_found then
    dbms_output.put_line('Employee not found');
end;
/

begin
    get_employee_by_id(101);
end;
/

// 5
create sequence employees_seq
start with 205
increment by 1;

create or replace procedure add_employee (
    p_first_name   in employees.first_name%type default 'Jan',
    p_last_name    in employees.last_name%type,
    p_email        in employees.email%type,
    p_salary       in employees.salary%type default 3000,
    p_hire_date    in employees.hire_date%type default sysdate,
    p_job_id       in employees.job_id%type default 'IT_PROG'
)
is
    ex_salary_too_high exception;
begin
    if p_salary > 20000 then
        raise ex_salary_too_high;
    end if;

    insert into employees (
        employee_id,
        first_name,
        last_name,
        email,
        hire_date,
        job_id,
        salary
    )
    values (
        employees_seq.nextval,
        p_first_name,
        p_last_name,
        p_email,
        p_hire_date,
        p_job_id,
        p_salary
    );

    dbms_output.put_line('Pracownik został dodany');

exception
    when ex_salary_too_high then
        dbms_output.put_line('Zbyt wysokie wynagrodzenie');

    when others then
        dbms_output.put_line('Inny błąd');
end;
/

begin
    add_employee(
        p_last_name => 'Kowalski',
        p_email     => 'JKOWALSKI',
        p_salary    => 25000
    );
end;
/

// 6
create or replace procedure avg_salary_by_manager (
    p_manager_id in  employees.manager_id%type,
    p_avg_salary out number
)
is
begin
    select avg(salary)
    into p_avg_salary
    from employees
    where manager_id = p_manager_id;

    if p_avg_salary is null then
        dbms_output.put_line('Manager o ID ' || p_manager_id || ' nie ma podwładnych.');
    else
        dbms_output.put_line('Średnia pensja podwładnych: ' || p_avg_salary);
    end if;

exception
    when others then
        dbms_output.put_line('Inny błąd');
end;
/

declare
    v_avg_salary number;
begin
    avg_salary_by_manager(100, v_avg_salary);
end;
/

// 7
create or replace procedure update_salary_in_department (
    p_department_id in employees.department_id%type,
    p_percent       in number
)
is
    v_new_salary employees.salary%type;
    v_min_salary jobs.min_salary%type;
    v_max_salary jobs.max_salary%type;

    ex_salary_out_of_range exception;
    pragma exception_init(ex_salary_out_of_range, -20001);

begin
    for emp_rec in (
        select e.employee_id, e.salary, e.job_id
        from employees e
        where e.department_id = p_department_id
    )
    loop
        select min_salary, max_salary
        into v_min_salary, v_max_salary
        from jobs
        where job_id = emp_rec.job_id;

        v_new_salary := emp_rec.salary * (1 + p_percent / 100);

        if v_new_salary < v_min_salary or v_new_salary > v_max_salary then
            raise_application_error(
                -20001,
                'Nowe wynagrodzenie pracownika ' || emp_rec.employee_id ||
                ' poza zakresem dla stanowiska!'
            );
        end if;

        update employees
        set salary = v_new_salary
        where employee_id = emp_rec.employee_id;

    end loop;

    dbms_output.put_line('Wynagrodzenia zostały zaktualizowane.');
    commit;

exception
    when ex_salary_out_of_range then
        rollback;
        dbms_output.put_line(sqlerrm);

    when others then
        if sqlcode = -2291 then
            dbms_output.put_line('Błąd: Podany department_id nie istnieje!');
        else
            dbms_output.put_line('Inny błąd');
        end if;
        rollback;
end;
/

begin
    update_salary_in_department(60, 10);
end;
/

// 8
create or replace procedure move_employee_to_department (
    p_employee_id       in employees.employee_id%type,
    p_new_department_id in departments.department_id%type
)
is
    emp_number number;
    dep_number number;
    ex_employee_not_found exception;
begin
    select count(*) into emp_number
    from employees
    where employee_id = p_employee_id;

    if emp_number = 0 then
        raise ex_employee_not_found;
    end if;

    select count(*) into dep_number
    from departments
    where department_id = p_new_department_id;

    if dep_number = 0 then
        raise_application_error(
            -20001,
            'Departament o podanym ID nie istnieje!'
        );
    end if;

    update employees
    set department_id = p_new_department_id
    where employee_id = p_employee_id;

    dbms_output.put_line(
        'Pracownik: ' || p_employee_id ||
        ' został przeniesiony do departamentu: ' || p_new_department_id
    );

exception
    when ex_employee_not_found then
        dbms_output.put_line(
            'Pracownik o ID: ' || p_employee_id || ' nie istnieje!'
        );
    when others then
        dbms_output.put_line('Inny błąd: ' || sqlerrm);
end;
/

begin
    move_employee_to_department(110, 1000);
end;
/

// 9
create or replace procedure delete_department_if_empty (
    p_department_id in departments.department_id%type
)
is
    v_emp_count number;
begin
    select count(*)
    into v_emp_count
    from employees
    where department_id = p_department_id;

    if v_emp_count > 0 then
        raise_application_error(
            -20001,
            'Departament nie jest pusty'
        );
    end if;

    delete from departments
    where department_id = p_department_id;

    if sql%rowcount = 0 then
        raise_application_error(
            -20001,
            'Departament o podanym ID nie istnieje.'
        );
    end if;

    dbms_output.put_line(
        'Departament o ID: ' || p_department_id || ' został usunięty.'
    );

exception
    when others then
        dbms_output.put_line('Inny błąd: ' || sqlerrm);
end;
/

begin
    delete_department_if_empty(60);
end;
/