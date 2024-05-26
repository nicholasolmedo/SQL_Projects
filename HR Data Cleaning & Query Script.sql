-- Create a schema for our project and make sure to use it for the rest of our script
CREATE DATABASE projects;
USE projects;

-- Preliminary look at the data
SELECT * FROM hr;

-- DATA CLEANING --

-- We clean up the id column name
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

-- Verify that the change worked
SELECT * FROM hr;

-- Identify the data types of each column
DESCRIBE hr;

-- We notice that the 'birthdate' column has strings. We want to convert all its records to 
-- the standard form of dates. Let's do that:
UPDATE hr
SET birthdate = CASE 
	WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL 
END;

-- The type of the 'birthdate' column is still text. So we change it to date:
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

-- The 'hire_date' column has the same problem. So we apply the same changes that we did to 'birthdate':
UPDATE hr
SET hire_date = CASE 
	WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL 
END;

-- We change the datatype of the 'hire_date' column to date:
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- Next, we clean the termdate column.
-- Set the entries to standard date format
UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE TRUE;

SELECT termdate FROM hr;
SET sql_mode = 'ALLOW_INVALID_DATES';

-- Set the column datatype to date 
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());

-- END CLEANING --
-----------------------------------
-- ANALYSIS QUESTIONS --

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(gender) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(race) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT CASE
	WHEN age >=18 AND age <=24 THEN '18-24'
    WHEN age >=25 AND age <=34 THEN '25-34'
    WHEN age >=35 AND age <=44 THEN '35-44'
    WHEN age >=45 AND age <=54 THEN '45-54'
    WHEN age >=55 AND age <=64 THEN '55-64'
    ELSE '65+' 
END AS age_group, gender,
COUNT(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group;
    
-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) AS count
FROM hr
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT ROUND(AVG(DATEDIFF(termdate, hire_date))/365, 2) AS avg_length_employment
FROM hr
WHERE age >=18 AND termdate != '0000-00-00' AND termdate <= CURDATE();
 
-- 6. How does the gender distribution vary across departments?
SELECT department, gender, COUNT(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*)
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?
SELECT department, total_count, terminated_count,
terminated_count/total_count AS termination_rate
FROM (
SELECT department, COUNT(*) AS total_count,
SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0
END) AS terminated_count
FROM hr
WHERE age >= 18
GROUP BY department
) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
	Year, 
	hires, 
    terminations,
	hires - terminations AS net_change,
	ROUND((hires - terminations) / hires * 100, 2) AS net_change_percent
FROM (
	SELECT 
		YEAR(hire_date) AS Year,
        COUNT(*) AS hires,
        SUM(CASE WHEN termdate != '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0
        END) AS terminations
	FROM hr
	WHERE age >= 18
    GROUP BY Year(hire_date)
    ) AS subquery
ORDER BY Year ASC;

-- 11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(DATEDIFF(termdate, hire_date)/365), 2) AS avg_tenure
FROM hr
WHERE termdate <= CURDATE() AND termdate != '0000-00-00' AND age >= 18
GROUP BY department;


    
