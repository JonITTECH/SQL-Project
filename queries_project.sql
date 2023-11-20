USE sqlproject;

CREATE TABLE consolidated_data AS
SELECT
    schools.school_id AS school_id,
    schools.school AS school_name,
    schools_badges.badges_id AS badges_id
##    badges_name.badges_name AS badges_name,
FROM
    schools
JOIN
	schools_badges ON schools_badges.school_id=schools.school_id;

CREATE TABLE consolidated_data_2
SELECT
    consolidated_data.school_id AS school_id,
    consolidated_data.school_name AS school_name,
    consolidated_data.badges_id AS badges_id,
    badges_name.badges_name AS badges_name
FROM
    consolidated_data 
JOIN
    badges_name ON consolidated_data.badges_id=badges_name.badges_id;

SELECT * FROM consolidated_data_2;

DROP TABLE consolidated_data;

RENAME TABLE consolidated_data_2 TO consolidated_data;

ALTER TABLE locations RENAME COLUMN `country.name` TO country_name;
ALTER TABLE locations RENAME COLUMN `city.name` TO city_name;
ALTER TABLE locations RENAME COLUMN `state.name` TO state_name;
SELECT * FROM locations;

ALTER TABLE consolidated_data
ADD COLUMN country TEXT, ADD COLUMN city TEXT,ADD COLUMN state TEXT; 
SET SQL_SAFE_UPDATES = 0;

UPDATE consolidated_data
JOIN locations
ON consolidated_data.school_id = locations.school_id
SET consolidated_data.country = locations.country_name,
    consolidated_data.city = locations.city_name,
    consolidated_data.state = locations.state_name;

SELECT * FROM consolidated_data;

CREATE TABLE school_reviews
SELECT
    school_id,
    AVG(overallScore) AS overall_review,
	AVG(curriculum) AS overall_cv,
	AVG(jobSupport) AS overall_job
FROM comments
GROUP BY school_id;

CREATE TABLE course_reviews
SELECT
    school_id AS school_id,
    hostProgramName AS course,
    AVG(overallScore) AS overall_review,
	AVG(curriculum) AS overall_cv,
	AVG(jobSupport) AS overall_job
FROM comments
GROUP BY
    school_id,
    hostProgramName;
    
ALTER TABLE consolidated_data
ADD COLUMN overall_review double, ADD COLUMN overall_cv double,ADD COLUMN overall_job double; 

UPDATE consolidated_data
JOIN school_reviews
ON consolidated_data.school_id = school_reviews.school_id
SET consolidated_data.overall_review = school_reviews.overall_review, consolidated_data.overall_cv = school_reviews.overall_cv, consolidated_data.overall_job = school_reviews.overall_job;

ALTER TABLE consolidated_data 
ADD COLUMN flag_online int, 
ADD COLUMN flag_flexible int, 
ADD COLUMN flag_job int, 
ADD COLUMN flag_outcomes int, 
ADD COLUMN flag_bill int, 
ADD COLUMN flag_vet int;

UPDATE consolidated_data
SET flag_online = CASE WHEN badges_id = 1 THEN 1 ELSE 0 END, 
flag_flexible = CASE WHEN badges_id = 2 THEN 1 ELSE 0 END,
flag_job = CASE WHEN badges_id = 3 THEN 1 ELSE 0 END,
flag_outcomes = CASE WHEN badges_id = 4 THEN 1 ELSE 0 END,
flag_bill= CASE WHEN badges_id = 5 THEN 1 ELSE 0 END,
flag_vet = CASE WHEN badges_id = 6 THEN 1 ELSE 0 END;

ALTER TABLE consolidated_data 
DROP COLUMN badges_id, 
DROP COLUMN badges_name;

CREATE TABLE consolidated_data_2 AS
SELECT
    school_id,
    SUM(flag_online) AS flag_online_school,
	SUM(flag_flexible) AS flag_flexible_school,
	SUM(flag_job) AS flag_job_school,
	SUM(flag_outcomes) AS flag_outcomes_school,
	SUM(flag_bill) AS flag_bill_school,
	SUM(flag_vet) AS flag_vet_school
FROM
    consolidated_data
GROUP BY
    school_id;

ALTER TABLE consolidated_data 
ADD COLUMN flag_online_school decimal, 
ADD COLUMN flag_flexible_school decimal, 
ADD COLUMN flag_job_school decimal, 
ADD COLUMN flag_outcomes_school decimal, 
ADD COLUMN flag_bill_school decimal, 
ADD COLUMN flag_vet_school decimal;

UPDATE consolidated_data
JOIN consolidated_data_2
ON consolidated_data.school_id = consolidated_data_2.school_id
SET 
    consolidated_data.flag_online_school = consolidated_data_2.flag_online_school,
    consolidated_data.flag_flexible_school = consolidated_data_2.flag_flexible_school,
    consolidated_data.flag_job_school = consolidated_data_2.flag_job_school,
    consolidated_data.flag_outcomes_school = consolidated_data_2.flag_outcomes_school,
    consolidated_data.flag_bill_school = consolidated_data_2.flag_bill_school,
    consolidated_data.flag_vet_school = consolidated_data_2.flag_vet_school;

select * from consolidated_data;

