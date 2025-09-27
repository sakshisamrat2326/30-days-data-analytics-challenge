


use [Bank Loan DB]

-- 1]  Key_Performace_Indicator

--1.1 Total Loan Applications
SELECT *FROM bank_loan_data
--
SELECT COUNT(id) AS Total_Loan_Applications FROM bank_loan_data

--1.2 PMTD/MTD Loan Application
SELECT COUNT(id) AS PMTD_Total_Loan_Applications FROM bank_loan_data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021

--2) Total Funded Amount

SELECT SUM(loan_amount) AS MTD_Total_funded_amount FROM bank_loan_data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021

--previous month
SELECT SUM(loan_amount) AS PMTD_Total_funded_amount FROM bank_loan_data
WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021

--3) Total Amount Received

SELECT SUM(total_payment) AS MTD_total_payment_received FROM bank_loan_data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021

SELECT SUM(total_payment) AS PMTD_total_payment_received FROM bank_loan_data
WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021

--4) Avg interest rate
SELECT ROUND(AVG(int_rate),4) * 100 AS AVG_int_rate FROM bank_loan_data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021

--5) Avg_Debt to income ratio

SELECT ROUND(AVG(dti)*100,4) AS avg_dti from bank_loan_data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021 --dti shoudn't be high as well as low 30-35-25 


---2] Good performance vs Bad Performance KPI's


--Good loan percentage
SELECT loan_status from bank_loan_data
SELECT (COUNT(CASE WHEN loan_status='fully paid' OR loan_status='current' THEN id end)*100)  
/
COUNT (id) AS Good_Loan_Percentage
from bank_loan_data

--Good Loan Applications

SELECT COUNT(ID) AS Good_Loan_applications FROM bank_loan_data
WHERE  loan_status='fully paid ' OR loan_status='current'

--Funded amount
SELECT SUM(loan_amount) AS Good_Loan_funded_amount FROM bank_loan_data
WHERE  loan_status='fully paid ' OR loan_status='current'

--total amount received
SELECT SUM(total_payment) AS Good_Loan_Total_amount_received FROM bank_loan_data
WHERE  loan_status='fully paid ' OR loan_status='current'


/* Invested -> 370224850
   Recieved ->435786170 -> insight bank is making profit */

   -- BAD LOAN 

   --PERCENTAGE
SELECT
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0) / 
	COUNT(id) AS Bad_Loan_Percentage
FROM bank_loan_data

-- Bad Loan Applications
SELECT COUNT(id) AS Bad_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Charged Off'


-- LOAN STATUS
	SELECT
        loan_status,
        COUNT(id) AS LoanCount,
        SUM(total_payment) AS Total_Amount_Received,
        SUM(loan_amount) AS Total_Funded_Amount,
        AVG(int_rate * 100) AS Interest_Rate,
        AVG(dti * 100) AS DTI
    FROM
        bank_loan_data
    GROUP BY
        loan_status

		
SELECT 
	loan_status, 
	SUM(total_payment) AS MTD_Total_Amount_Received, 
	SUM(loan_amount) AS MTD_Total_Funded_Amount 
FROM bank_loan_data
WHERE MONTH(issue_date) = 12 
GROUP BY loan_status


-- B.	BANK LOAN REPORT | OVERVIEW
-- MONTH
SELECT 
	MONTH(issue_date) AS Month_Munber, 
	DATENAME(MONTH, issue_date) AS Month_name, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date)



-- Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_Loan_Funded_amount FROM bank_loan_data
WHERE loan_status = 'Charged Off'

-- Bad Loan Amount Received
SELECT SUM(total_payment) AS Bad_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Charged Off'


-- STATE
SELECT 
	address_state AS State, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY address_state
ORDER BY address_state


-- TERM
SELECT 
	term AS Term, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY term
ORDER BY term

--EMPLOYEE LENGTH
SELECT 
	emp_length AS Employee_Length, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY emp_length
ORDER BY emp_length


-- PURPOSE
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY purpose
ORDER BY purpose



-- HOME OWNERSHIP
SELECT 
	home_ownership AS Home_Ownership, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY home_ownership
ORDER BY home_ownership


-- See the results when we hit the Grade A in the filters for dashboards.
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
WHERE grade = 'A'
GROUP BY purpose
ORDER BY purpose
