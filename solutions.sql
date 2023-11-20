USE sqlproject; 
​-- first review all tables:
SELECT * FROM comments;
SELECT * FROM badges_name;
SELECT * FROM schools_badges;
SELECT * FROM courses;
##SELECT * FROM description;
SELECT * FROM locations; 
​
​
-- COMMENTS create a PK
SELECT * FROM comments;
describe comments;
ALTER TABLE comments ADD PRIMARY KEY (id);
ALTER TABLE comments RENAME COLUMN id TO comments_id;
SELECT * FROM comments;
​

-- BADGES
SELECT * FROM badges;
describe badges;
ALTER TABLE badges
ADD badges_id INT PRIMARY KEY AUTO_INCREMENT;
SELECT * FROM badges; 
ALTER TABLE badges DROP COLUMN school;
​
-- DESCRIPTIVE ANALYSIS COMPARING name vs. keyword
SELECT DISTINCT keyword FROM schools_badges;
SELECT DISTINCT name FROM badges;
SELECT DISTINCT keyword, name FROM badges;
SELECT * from badges;
​-- Ok!

-- COURSES:
SELECT * FROM courses;
describe courses;
ALTER TABLE courses
ADD course_id INT PRIMARY KEY AUTO_INCREMENT;
SELECT * FROM courses;
​
describe courses;
​
​
-- Create a table with schools & school_id per school as PK 
CREATE TABLE schools (school text, school_id bigint); 
INSERT INTO schools (school, school_id)
SELECT DISTINCT school, school_id
FROM courses;
ALTER TABLE schools ADD PRIMARY KEY(school_id);
​
-- DROP schools FROM courses
ALTER TABLE courses DROP COLUMN school;
SELECT * FROM courses;
​-- Drop column 
ALTER TABLE courses DROP COLUMN courses;
​
SELECT * FROM courses;
​
-- DESCRIPTION: 
SELECT * FROM description;
ALTER TABLE description
#describe description; 
​
-- LOCATIONS:
SELECT * FROM locations;
describe locations;
ALTER TABLE locations ADD PRIMARY KEY (id);
SELECT * FROM locations;
ALTER TABLE locations RENAME COLUMN id TO locations_id;
ALTER TABLE locations DROP COLUMN description;
ALTER TABLE locations DROP COLUMN `state.keyword`;
ALTER TABLE locations DROP COLUMN `city.keyword`;

ALTER TABLE locations
DROP COLUMN `city.id`, DROP COLUMN `state.id`, DROP COLUMN `country.id`, DROP COLUMN `state.abbrev`, DROP COLUMN `country.abbrev`;
SELECT * FROM badges;
select * from schools;
SELECT schools.school_id, schools.school, badges.badges_id from schools LEFT JOIN badges ON badges.school_id = schools.school_id;
​
ALTER TABLE badges RENAME TO schools_badges;
SELECT * FROM schools_badges;
​
​
-- create a table for the badges names:
CREATE TABLE badges_name (badges_name text) ;
insert into badges_name (badges_name)
SELECT DISTINCT schools_badges.name
FROM schools_badges;
ALTER TABLE badges_name
ADD badges_id INT PRIMARY KEY AUTO_INCREMENT;
select * from badges_name;
​
SELECT * FROM schools_badges;
​
ALTER TABLE schools_badges DROP COLUMN badges_id, DROP COLUMN description, DROP COLUMN keyword; 
SELECT * FROM schools_badges;

select * from badges_name; 
select * from schools_badges;
ALTER TABLE schools_badges
ADD COLUMN badges_id INT;
​
select badges_name.badges_id from badges_name;
​
UPDATE schools_badges
SET schools_badges.badges_id = badges_name.badges_id 
FROM schools_badges
WHERE schools_badges.name = badges_name.name;
​
## map schools vs badges: 
UPDATE schools_badges
JOIN badges_name 
ON schools_badges.name = badges_name.badges_name
SET schools_badges.badges_id = badges_name.badges_id ;

​
-- aggr. info from description to schools: 
​
ALTER TABLE schools
DROP COLUMN school_description,
ADD COLUMN school_description TEXT;
describe schools;
-- describe description;
​
##join schools including description: 
UPDATE schools
JOIN description
ON schools.school = description.name
SET schools.school_description = description.description ;
select * from schools;
​
​##Replace symbols: 
UPDATE description
SET name = LOWER(REPLACE(name, ' ', '-'));
select * from description; 
UPDATE description
SET name = REPLACE(name, '-&-', ' ');
select * from description; 
DROP TABLE description;
​
​
select * from comments;
​
ALTER TABLE comments
ADD COLUMN school_id BIGINT;
describe schools;
UPDATE comments
JOIN schools
ON schools.school = comments.school
SET comments.school_id = schools.school_id ;
​
ALTER TABLE comments DROP COLUMN school;
select * from comments;


-- Consolidate results:
-- first include badges names; 
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


-- treatment for locations:
SELECT * FROM locations;
alter table locations rename column `country.name` TO country_name;
alter table locations rename column `city.name` TO city_name;
alter table locations rename column `state.name` TO state_name;
SELECT * FROM locations;

-- include locations: 

ALTER TABLE consolidated_data
ADD COLUMN country TEXT, ADD COLUMN city TEXT,ADD COLUMN state TEXT; 
SET SQL_SAFE_UPDATES = 0;
UPDATE consolidated_data
JOIN locations
ON consolidated_data.school_id = locations.school_id
SET consolidated_data.country = locations.country_name, consolidated_data.city = locations.city_name, consolidated_data.state = locations.state_name; 

select distinct * from consolidated_data;

-- SELECT * FROM comments;
-- SELECT * FROM courses;

-- analyse reviews by schools: 
CREATE TABLE school_reviews
SELECT
    school_id,
    AVG(overallScore) AS overall_review,
	AVG(curriculum) AS overall_cv,
	AVG(jobSupport) AS overall_job
    
FROM
    comments
GROUP BY
    school_id;

select * from school_reviews;

-- analyse reviews by course: 
CREATE TABLE course_reviews
SELECT
    school_id AS school_id,
    hostProgramName AS course,
    AVG(overallScore) AS overall_review,
	AVG(curriculum) AS overall_cv,
	AVG(jobSupport) AS overall_job
    
FROM
    comments
GROUP BY
    school_id,
    hostProgramName;

-- include overall review to the consolidated table:
ALTER TABLE consolidated_data
ADD COLUMN overall_review double, ADD COLUMN overall_cv double,ADD COLUMN overall_job double; 
##SET SQL_SAFE_UPDATES = 0;
UPDATE consolidated_data
JOIN school_reviews
ON consolidated_data.school_id = school_reviews.school_id
SET consolidated_data.overall_review = school_reviews.overall_review, consolidated_data.overall_cv = school_reviews.overall_cv, consolidated_data.overall_job = school_reviews.overall_job;
select * from consolidated_data;

-- select * from badges_name;

select * from school_reviews;
describe school_reviews;

-- include flag for each benefit: 

ALTER TABLE consolidated_data ADD column flag_online int, add column flag_flexible int, add column flag_job int, add column flag_outcomes int, add column flag_bill int, add column flag_vet int;
UPDATE consolidated_data
SET flag_online = CASE WHEN badges_id = 1 THEN 1 ELSE 0 END, 
flag_flexible = CASE WHEN badges_id = 2 THEN 1 ELSE 0 END,
flag_job = CASE WHEN badges_id = 3 THEN 1 ELSE 0 END,
flag_outcomes = CASE WHEN badges_id = 4 THEN 1 ELSE 0 END,
flag_bill= CASE WHEN badges_id = 5 THEN 1 ELSE 0 END,
flag_vet = CASE WHEN badges_id = 6 THEN 1 ELSE 0 END;

select * from consolidated_data;

alter table consolidated_data DROP COLUMN badges_id, DROP COLUMN badges_name;


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
SELECT * FROM consolidated_data_2;

-- ALTER TABLE data_table ADD column flag_online_school decimal(32,0), add column flag_flexible_school decimal(32,0), add column flag_job_school decimal(32,0), add column flag_outcomes_school decimal(32,0), add column flag_bill_school decimal(32,0), add column flag_vet_school decimal(32,0);

UPDATE consolidated_data
JOIN consolidated_data_2
ON consolidated_data.school_id = consolidated_data_2.school_id
SET consolidated_data.flag_online_school = consolidated_data_2.flag_online_school,
consolidated_data.flag_flexible_school = consolidated_data_2.flag_flexible_school,
consolidated_data.flag_job_school = consolidated_data_2.flag_job_school,
consolidated_data.flag_outcomes_school = consolidated_data_2.flag_outcomes_school,
consolidated_data.flag_bill_school = consolidated_data_2.flag_bill_school,
consolidated_data.flag_vet_school = consolidated_data_2.flag_vet_school;
select * from schools;
select * from consolidated_data;
select * from consolidated_data_2;

select * from consolidated_data;

create table final_data
select distinct * from consolidated_data;

-- obtain the final information without duplicates: 

select * from final_data;

describe final_data;
-- include a final metric that summarises the result:
-- alter TABLE final_data DROP COLUMN result;
alter TABLE final_data ADD COLUMN result DOUBLE;
UPDATE final_data 
SET result = overall_review + overall_cv + overall_job + 
CONVERT(flag_online_school, DOUBLE) +
CONVERT(flag_flexible_school, DOUBLE) + 
CONVERT(flag_flexible_school, DOUBLE) + 
CONVERT(flag_job_school, DOUBLE) + 
CONVERT(flag_outcomes_school, DOUBLE) + 
CONVERT(flag_bill_school, DOUBLE) + 
CONVERT(flag_vet_school, DOUBLE);
