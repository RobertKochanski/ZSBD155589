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