// 1
create or replace function get_job_by_id
    (f_job_id in jobs.job_id%type) 
    return jobs.job_title%type
is
    v_job_title jobs.job_title%type;
    job_not_found exception;
begin
    select job_title into v_job_title
    from jobs
    where job_id = f_job_id;
    
    return v_job_title;
    
exception
when no_data_found then
    dbms_output.put_line('Job not found');
    return null;
when others then
    dbms_output.put_line('Inny blad: ' || sqlerrm);
    return null;
end;
/

declare
    job_title jobs.job_title%type;
begin
    job_title := get_job_by_id('IT_OG');
    dbms_output.put_line(job_title);
end;
/

// 2
create or replace function get_employee_year_salary
    (f_employee_id employees.employee_id%type)
    return number
is
    v_year_salary number(10, 2);
begin
    select round((salary + (salary * nvl(commission_pct, 0))) * 12, 2) into v_year_salary
    from employees
    where employee_id = f_employee_id;
    
    return v_year_salary;
    
exception
when no_data_found then
    dbms_output.put_line('Employee not found');
    return null;
when others then
    dbms_output.put_line('Inny blad: ' || sqlerrm);
    return null;
end;
/

declare
    year_salary number;
begin
    year_salary := get_employee_year_salary(145);
    dbms_output.put_line(year_salary);
end;
/

// 3
create or replace function get_kierunkowy (
    p_telefon in varchar2
) return varchar2
is
    v_kierunkowy varchar2(10);
begin
    v_kierunkowy := substr(
                        p_telefon,
                        instr(p_telefon, '(') + 1,
                        instr(p_telefon, ')') - instr(p_telefon, '(') - 1
                    );
    return v_kierunkowy;
exception
    when others then
        return null;
end;
/

declare
    kierunkowy varchar2(10);
begin
    kierunkowy := get_kierunkowy('(48) 123 456 789');
    dbms_output.put_line(kierunkowy);
end;
/

// 4
create or replace function format_pierwsza_ostatnia (
    p_tekst in varchar2
) return varchar2
is
    v_dl   number;
    v_wynik varchar2(100);
begin
    v_dl := length(p_tekst);

    if p_tekst is null or v_dl = 1 or v_dl = 2 then
        return upper(p_tekst);
    end if;

    v_wynik :=
          upper(substr(p_tekst, 1, 1))
       || lower(substr(p_tekst, 2, v_dl - 2))
       || upper(substr(p_tekst, v_dl, 1));

    return v_wynik;
end;
/

declare
    tekst varchar2(100);
begin
    tekst := format_pierwsza_ostatnia('jakis losowY tekst Do forMatowania');
    dbms_output.put_line(tekst);
end;
/

// 5
create or replace function pesel_na_date (
    p_pesel in varchar2
) return varchar2
is
    v_rok   number;
    v_mies  number;
    v_dzien number;
    v_wiek  number;
    v_data  date;
begin
    if length(p_pesel) <> 11 then
        return null;
    end if;

    v_rok   := to_number(substr(p_pesel, 1, 2));
    v_mies  := to_number(substr(p_pesel, 3, 2));
    v_dzien := to_number(substr(p_pesel, 5, 2));

    if v_mies between 1 and 12 then
        v_wiek := 1900;
    elsif v_mies between 21 and 32 then
        v_wiek := 2000;
        v_mies := v_mies - 20;
    elsif v_mies between 41 and 52 then
        v_wiek := 2100;
        v_mies := v_mies - 40;
    elsif v_mies between 61 and 72 then
        v_wiek := 2200;
        v_mies := v_mies - 60;
    elsif v_mies between 81 and 92 then
        v_wiek := 1800;
        v_mies := v_mies - 80;
    else
        return null;
    end if;

    v_data := to_date(
                  v_wiek + v_rok || 
                  lpad(v_mies, 2, '0') || 
                  lpad(v_dzien, 2, '0'),
                  'YYYYMMDD'
              );

    return to_char(v_data, 'YYYY-MM-DD');

exception
    when others then
        return null;
end;
/

declare
    pesel varchar2(20);
begin
    pesel := pesel_na_date('99072605150');
    dbms_output.put_line(pesel);
end;
/

// 6
create or replace function statystyka_kraju (
    p_nazwa_kraju in varchar2
) return varchar2
is
    v_liczba_pracownikow  number;
    v_liczba_departamentow number;
    v_czy_istnieje number;
begin
    select count(*)
    into v_czy_istnieje
    from countries
    where upper(country_name) = upper(p_nazwa_kraju);

    if v_czy_istnieje = 0 then
        raise_application_error(-20001, 'Podany kraj nie istnieje!');
    end if;

    select count(e.employee_id)
    into v_liczba_pracownikow
    from employees e
    join departments d  on e.department_id = d.department_id
    join locations l    on d.location_id = l.location_id
    join countries c    on l.country_id = c.country_id
    where upper(c.country_name) = upper(p_nazwa_kraju);

    select count(distinct d.department_id)
    into v_liczba_departamentow
    from departments d
    join locations l  on d.location_id = l.location_id
    join countries c on l.country_id = c.country_id
    where upper(c.country_name) = upper(p_nazwa_kraju);
    return 
        'Kraj: ' || p_nazwa_kraju ||
        ', Pracownicy: ' || v_liczba_pracownikow ||
        ', Departamenty: ' || v_liczba_departamentow;
exception
when others then
    dbms_output.put_line('Inny blad: ' || sqlerrm);
end;
/


declare
    wynik varchar2(200);
begin
    wynik := statystyka_kraju('United States of America');
    dbms_output.put_line(wynik);
end;
/

// 7
create or replace function generuj_id(
    p_imie     in varchar2,
    p_nazwisko in varchar2,
    p_telefon  in varchar2
) return varchar2
is
    v_nazwisko_3  varchar2(3);
    v_telefon_4   varchar2(4);
    v_inicjal     varchar2(1);
    v_tel_czysty  varchar(12);
begin
    if p_imie is null or p_nazwisko is null or p_telefon is null then
        raise_application_error(-20002, 'Wszystkie parametry muszą być podane!');
    end if;

    if length(p_nazwisko) < 3 then
        raise_application_error(-20003, 'Nazwisko musi mieć co najmniej 3 znaki!');
    end if;

    v_tel_czysty := regexp_replace(p_telefon, '[^0-9]', '');

    if length(v_tel_czysty) < 4 then
        raise_application_error(-20004, 'Numer telefonu musi mieć co najmniej 4 cyfry!');
    end if;

    v_nazwisko_3 := upper(substr(p_nazwisko, 1, 3));
    v_telefon_4 := substr(v_tel_czysty, -4);
    v_inicjal := upper(substr(p_imie, 1, 1));

    return v_nazwisko_3 || v_telefon_4 || v_inicjal;
end;
/

declare
    wynik varchar2(8);
begin
    wynik := generuj_id('Robert', 'Kochański', '123 456 789');
    dbms_output.put_line(wynik);
end;
/