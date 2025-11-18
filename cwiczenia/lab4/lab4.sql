// 1
select first_name, last_name, salary,
    rank() over(order by salary desc) as salary_rank
from employees;

// 2
select first_name, last_name, salary, 
    sum(salary) over() as salary_sum
from employees;

// 3
select e.last_name, p.product_name,
    sum(s.quantity * s.price) as total_sale_value,
    rank() over(order by sum(s.quantity * s.price) desc) as sales_rank
from employees e
    join sales s on e.employee_id = s.employee_id
    join products p on s.product_id = p.product_id
group by e.last_name, p.product_name;


// 4
select e.last_name, p.product_name, s.price,
    count(*) over (
        partition by s.product_id, trunc(s.sale_date)
    ) as transactions_per_product_day,
    sum(s.price * s.quantity) over (
        partition by s.product_id, trunc(s.sale_date)
    ) as sum_paid_per_product_day,
    lag(s.price) over (
        partition by s.product_id
        order by s.sale_date, s.sale_id
    ) as prev_price,
    lead(s.price) over (
        partition by s.product_id
        order by s.sale_date, s.sale_id
    ) as next_price
from sales s
join employees e on e.employee_id = s.employee_id
join products p on p.product_id = s.product_id;

// 5
select p.product_name, s.price,
    sum(s.price * s.quantity) over (
        partition by p.product_id,
                     trunc(s.sale_date, 'MM')
    ) as monthly_sum_per_product,
    sum(s.price * s.quantity) over (
        partition by p.product_id, trunc(s.sale_date, 'MM')
        order by s.sale_date, s.sale_id
        rows between unbounded preceding and current row
    ) as monthly_running_total
from sales s
join products p on p.product_id = s.product_id;

// 6
select (extract(month from s22.sale_date)||'.'|| extract(day from s22.sale_date)) as sale_date, p.product_name, 
p.product_category, s22.price as price_2022, s23.price as price_2023, abs(s23.price - s22.price) as price_difference
from products p
left join sales s22 on s22.product_id = p.product_id
    and extract(year from s22.sale_date) = 2022
left join sales s23 on s23.product_id = p.product_id
    and extract(year from s23.sale_date) = 2023
    and extract(month from s23.sale_date) = extract(month from s22.sale_date)
    and extract(day from s23.sale_date) = extract(day from s22.sale_date)
where s22.sale_id is not null;

// 7
select p.product_category, p.product_name, s.price,
    min(s.price) over (
        partition by p.product_category
    ) as min_price_in_category,
    max(s.price) over (
        partition by p.product_category
    ) as max_price_in_category,
    (max(s.price) over (partition by p.product_category) -
     min(s.price) over (partition by p.product_category)) as price_diff_in_category
from sales s
join products p on p.product_id = s.product_id;

// 8
select p.product_name, s.sale_date, s.price,
    round(avg(s.price) over (
        partition by p.product_id
        order by s.sale_date, s.sale_id
        rows between 1 preceding and 1 following
    ), 2) as moving_average_price
from sales s
join products p on p.product_id = s.product_id;

// 9
select p.product_name, p.product_category, s.price,
    rank() over (
        partition by p.product_category
        order by s.price
    ) as price_rank,
    row_number() over (
        partition by p.product_category
        order by s.price
    ) as price_row_number,
    dense_rank() over (
        partition by p.product_category
        order by s.price
    ) as price_dense_rank
from sales s
join products p on p.product_id = s.product_id;

// 10
select e.last_name, p.product_name,
    sum(s.price * s.quantity) over (
        partition by s.employee_id
        order by s.sale_date, s.sale_id
        rows between unbounded preceding and current row
    ) as running_sales_value_employee,
    rank() over (
        order by (s.price * s.quantity) desc
    ) as global_order_value_rank
from sales s
join employees e on e.employee_id = s.employee_id
join products p on p.product_id = s.product_id;

// 11
select distinct e.first_name, e.last_name, j.job_title
from employees e
join sales s on e.employee_id = s.employee_id
join jobs j on e.job_id = j.job_id;