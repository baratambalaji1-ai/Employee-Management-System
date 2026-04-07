create database sql_project;
use sql_project;


-- Table 1 : Job Department
create table JobDepartment(
job_id int primary key,
jobdept varchar(50),
name varchar(100),
description text,
salaryrange varchar(50)
);

select * from JobDepartment;


-- Table 2: Salary/Bonus
create table SalaryBonus(
salary_id int primary key,
job_id int,
amount decimal(10,2),
annual decimal(10,2),
bonus decimal(10,2),
CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
ON DELETE CASCADE ON UPDATE CASCADE
);

select * from SalaryBonus;

-- Table 3: Employee

create table Employee(
emp_ID INT PRIMARY KEY,
firstname VARCHAR(50),
lastname VARCHAR(50),
gender VARCHAR(10),
age INT,
contact_add VARCHAR(100),
emp_email VARCHAR(100) UNIQUE,
emp_pass VARCHAR(50),
Job_ID INT,
CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
REFERENCES JobDepartment(Job_ID)
ON DELETE SET NULL
ON UPDATE CASCADE
);

select * from Employee;

-- Table 4: Qualification

create table Qualification(
QualId int primary key,
emp_id int,
position varchar(50),
Requirements VARCHAR(255),
Date_In DATE,
CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
REFERENCES Employee(emp_ID)
ON DELETE CASCADE
ON UPDATE CASCADE
);

select * from Qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
leave_ID INT PRIMARY KEY,
emp_ID INT,
date DATE,
reason TEXT,
CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
ON DELETE CASCADE ON UPDATE CASCADE
);


select *  from Leaves;

-- Table 6: Payroll
CREATE TABLE Payroll (
payroll_ID INT PRIMARY KEY,
emp_ID INT,
job_ID INT,
salary_ID INT,
leave_ID INT,
date DATE,
report TEXT,
total_amount DECIMAL(10,2),
CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
ON DELETE SET NULL ON UPDATE CASCADE
);

select * from Payroll;


-- Analysis Questions
-- 1.EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?

select count(*) as total_employees from Employee;

select count(emp_id) as total_emp from Employee;


-- Which departments have the highest number of employees?
SELECT jd.jobdept, COUNT(e.emp_ID) AS total_employees
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
order by total_employees desc;

select jobdept,total_employees,
    rank() OVER (partition by e.emp_ID order by total_employees desc) as dept_rank
from (select
        jd.jobdept,
        COUNT(e.emp_ID) as total_employees
    from Employee e
    join JobDepartment jd 
        on e.Job_ID = jd.Job_ID
    group by jd.jobdept
) as dept_count;



-- correct code of Second Question ******* Very important so we can use these code for ppt

SELECT jobdept,total_employees
FROM (
    select 
        jd.jobdept,
        COUNT(e.emp_ID) as total_employees,
        rank() over (order by COUNT(e.emp_ID) desc) as dept_rank
    from Employee e
    join JobDepartment jd 
        on e.Job_ID = jd.Job_ID
    group by jd.jobdept
) ranked_dept
where dept_rank = 1;


-- What is the average salary per department?
select jd.jobdept,avg(sb.amount) as avg_salary
from employee e
join JobDepartment jd on e.job_id = jd.job_id
join SalaryBonus sb on jd.job_id = sb.job_id
group by jd.jobdept; 




-- Who are the top 5 highest-paid employees?
select e.firstname,e.lastname,sb.amount
from employee e
join salarybonus as sb on e.job_id = sb.job_id
order by sb.amount desc
limit 5;





-- What is the total salary expenditure across the company?

select sum(sb.amount) as Total_Salary_Expenditure
from  salarybonus sb;


select sum(sb.amount) as Total_Salary_Expenditure
from  employee e
join salarybonus sb on e.job_id = sb.job_id;



-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
select count(jd.name) as job_roles
from jobdepartment jd
order by job_roles desc;


-- Orginal Code for these question**** Correct Code
select jd.jobdept, COUNT(jd.name) AS job_roles
from jobdepartment jd
group by jd.jobdept
order by jd.jobdept desc;


-- What is the average salary range per department?
select jd.jobdept,avg(sb.amount) as average_salary
from jobdepartment jd
join salarybonus sb on 
jd.job_id = sb.job_id
group by jd.jobdept
order by jd.jobdept desc;

-- Which Job roles offer the highest salary
select jd.name as job_role, 
sb.amount as salary
from JobDepartment jd
join SalaryBonus sb
on jd.job_id = sb.job_id
order by sb.amount desc;


-- Both Codes Are Same Can We Can use Both The Codes To complete these Problem
select jd.name as job_names,
max(sb.amount) as Highest_Amount
from jobdepartment jd
join salarybonus sb on
jd.job_id = sb.job_id
group by job_names
order by Highest_Amount desc;



-- Which departments have the highest total salary allocation?

-- These Code is Normal Gives only one 
select jd.jobdept, sum(sb.amount) as total_highest_Salary
from jobdepartment as jd
join salarybonus sb on
jd.job_id = sb.job_id
group by jd.jobdept
order by total_highest_Salary desc;

-- These Code is Used for Ranking Only One Department
SELECT jobdept, total_salary
FROM (
    SELECT jd.jobdept, 
           SUM(sb.amount) AS total_salary,
           RANK() OVER (ORDER BY SUM(sb.amount) DESC) AS dept_rank
    FROM jobdepartment jd
    JOIN salarybonus sb 
        ON jd.job_id = sb.job_id
    GROUP BY jd.jobdept
) ranked_dept
WHERE dept_rank = 1;


-- LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?
select year(date) as leave_year,
count(*) as total_leaves from Leaves
group by year(date)
order by total_leaves desc;

-- What is the average number of leave days taken by its employees per department?
select jd.jobdept,
avg(emp_leave.total_leaves) as avg_leave_days
from (select emp_ID, COUNT(*) as total_leaves from Leaves
group by emp_ID)as  emp_leave
join Employee e on emp_leave.emp_ID = e.emp_ID
join JobDepartment jd 
on e.Job_ID = jd.Job_ID
group by jd.jobdept
order by avg_leave_days desc;


-- Which employees have taken the most leaves?
SELECT e.emp_ID,e.firstname,e.lastname,
sum(l.leave_ID) as total_leaves
from Leaves l
join Employee e 
on l.emp_ID = e.emp_ID
group by e.emp_ID, e.firstname, e.lastname
order by total_leaves desc;
-- 2
SELECT e.emp_ID,e.firstname,e.lastname,
count(l.leave_ID) as total_leaves
from Leaves l
join Employee e 
on l.emp_ID = e.emp_ID
group by e.emp_ID, e.firstname, e.lastname
order by total_leaves desc;


-- What is the total number of leave days taken company-wide?
select count(*) as total_number_of_leaves
from Leaves;

-- How do leave days correlate with payroll amounts?
SELECT 
    e.emp_ID,
    COUNT(l.leave_ID) AS total_leaves,
    SUM(p.total_amount) AS total_salary
FROM Employee e
LEFT JOIN Leaves l 
    ON e.emp_ID = l.emp_ID
LEFT JOIN Payroll p 
    ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID;


-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
select year(date) as year,
month(date) as month,
sum(total_amount) as total_monthly_payroll
from Payroll
group by year(date),month(date)
order by year,month;

-- What is the average bonus given per department?
select jd.jobdept,avg(sb.bonus) as average_bonus
from  jobdepartment jd
join salarybonus sb on
jd.job_id = sb.job_id
group by jd.jobdept
order by average_bonus desc;

select * from jobdepartment;


-- Which department receives the highest total bonuses?
select jobdept, total_bonus
from (select jd.jobdept,sum(sb.bonus) AS total_bonus,
           rank() over(order by sum(sb.bonus) DESC) AS dept_rank
    from jobdepartment jd
    join salarybonus sb 
        on jd.job_id = sb.job_id
    group by jd.jobdept
) ranked_dept
where dept_rank = 1;

-- What is the average value of total_amount after considering leave deductions?
select avg(adjusted_salary) AS avg_adjusted_amount
FROM (
    select 
        p.emp_ID,
        p.total_amount - COUNT(l.leave_ID) * 500 AS adjusted_salary
    from Payroll p
    left join Leaves l 
        on p.emp_ID = l.emp_ID
    group by p.emp_ID, p.total_amount
) salary_calc;



-- Challenges
-- Defining correct table relationships and ensuring accurate use of foreign keys.
ALTER TABLE Employee
ADD CONSTRAINT fk_job
FOREIGN KEY (job_id)
REFERENCES JobDepartment(job_id);


-- For Payroll
ALTER TABLE Payroll
ADD CONSTRAINT fk_employee
FOREIGN KEY (emp_ID)
REFERENCES Employee(emp_ID);

-- Maintaining data consistency with cascading updates and deletes.

FOREIGN KEY (emp_ID)
REFERENCES Employee(emp_ID)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Writing complex joins for reports involving employee roles, leaves, and payroll.

SELECT e.firstname,
       jd.jobdept,
       COUNT(l.leave_ID) AS leaves,
       SUM(p.total_amount) AS salary
FROM Employee e
JOIN JobDepartment jd ON e.job_id = jd.job_id
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
LEFT JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID;


-- Ensuring all date fields follow the YYYY-MM-DD format for reliable time-based analysis.









