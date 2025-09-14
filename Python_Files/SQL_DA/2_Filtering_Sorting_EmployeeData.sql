



CREATE DATABASE EmployeeDB;
GO
USE EmployeeDB;
GO

USE EmployeeDB
CREATE TABLE Employee_Staging (
    employee_id VARCHAR(10),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    department VARCHAR(50),
    salary VARCHAR(20),
    joining_date VARCHAR(20),
    age VARCHAR(10)
);
GO

-- Bulk load
BULK INSERT Employee_Staging
FROM "C:\Users\Sakshi\Downloads\employee_data (1).csv"
WITH (
    FIRSTROW = 2,              -- skips the header row
    FIELDTERMINATOR = ',',      -- columns are comma-separated
    ROWTERMINATOR = '0x0d0a',  -- handles Windows line endings
    TABLOCK
);
GO

-- Final clean table
CREATE TABLE Employee_Data (
    employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    joining_date DATE,
    age INT
);
GO

-- Insert with type conversion
INSERT INTO Employee_Data (employee_id, first_name, last_name, email, department, salary, joining_date, age)
SELECT
    CAST(employee_id AS INT),
    first_name,
    last_name,
    email,
    department,
    CAST(salary AS DECIMAL(10,2)),
    CONVERT(DATE, joining_date, 103),  -- 103 = DD/MM/YYYY
    CAST(age AS INT)
FROM Employee_Staging;
GO

-- Verify data
SELECT TOP 10 *FROM Employee_Data

--1.View all Columns
SELECT *FROM Employee_Data

--2.Find Employees in IT Dept
SELECT *FROM Employee_Data
WHERE department= 'IT';

--3. Employees with salary greater than 50,000
SELECT first_name,last_name ,salary
FROM Employee_Data
WHERE salary>=50000

--4. Employees who joined after 2015
SELECT first_name,last_name, joining_date
FROM Employee_Data
WHERE joining_date>'2020' --joining_date  is smallint

--5. Count employees in each department:This is a classic aggregation — perfect for dashboards.
SELECT COUNT(*) AS Total_Employees
FROM Employee_Data
GROUP BY department

--6.Select Highest salary
SELECT MAX(Salary) as Highest_Salary
FROM Employee_Data

--7.Select Lowest Salary
SELECT MIN(Salary) as Lowest_Salary
FROM Employee_Data

--8. Average salary by department
SELECT AVG(Salary) as Average_Salary
FROM Employee_Data
GROUP BY department;

--9. Employees whose names start with ‘S’
SELECT first_name, last_name 
FROM Employee_Data
WHERE first_name LIKE '%S';

--10. Employees Older Than 5
SELECT first_name, age 
FROM employee_data 
WHERE age > 50;

--11. Top 5 Highest Paid Employee
SELECT TOP 5 first_name, last_name, CAST(salary AS INT) AS salary
FROM Employee_Data
ORDER BY CAST(salary AS INT) DESC;

--Combined filter
SELECT first_name, department, salary
FROM Employee_Data
WHERE department IN ('IT', 'HR')
  AND CAST(salary AS INT) > 90000; --salary as varchar, thus
