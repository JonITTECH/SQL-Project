USE sqlproject; 

SELECT * FROM comments;
SELECT * FROM badges;
SELECT * FROM courses;
SELECT * FROM description;
SELECT * FROM locations; 

-- COMMENTS create a PK
SELECT * FROM comments;
describe comments;
ALTER TABLE comments ADD PRIMARY KEY (id);
ALTER TABLE comments RENAME COLUMN id TO comments_id;
SELECT * FROM comments;

-- BADGES
SELECT * FROM badges;
describe badges;
ALTER TABLE badges
ADD badges_id INT PRIMARY KEY AUTO_INCREMENT;
SELECT * FROM badges; 
ALTER TABLE badges DROP COLUMN school;

-- DESCRIPTIVE ANALYSIS COMPARING name vs. keyword
SELECT DISTINCT keyword FROM schools_badges;
-- Volver aquí luego porque crearemos esta tabla: schools_badges
SELECT DISTINCT name FROM badges;
SELECT DISTINCT keyword, name FROM badges;
SELECT * from badges;

-- COURSES:
SELECT * FROM courses;
describe courses;
ALTER TABLE courses
ADD course_id INT PRIMARY KEY AUTO_INCREMENT;
SELECT * FROM courses;
describe courses;

-- Create a table with schools & school_id per school as PK 
CREATE TABLE schools (school text, school_id bigint); 
INSERT INTO schools (school, school_id)
SELECT DISTINCT school, school_id
FROM courses;
ALTER TABLE schools ADD PRIMARY KEY(school_id);

-- DROP schools FROM courses
ALTER TABLE courses DROP COLUMN school;
SELECT * FROM courses;
##ALTER TABLE courses DROP COLUMN course_format;
-- Agregar columnas nuevas
##ALTER TABLE courses
##ADD COLUMN course_name VARCHAR(50),
##ADD COLUMN course_format VARCHAR(50);
##SET SQL_SAFE_UPDATES = 0;
-- Actualizar las nuevas columnas con los valores divididos
#UPDATE courses
#SET course_name = SUBSTRING_INDEX(courses, ' -', 1),
#    course_format = SUBSTRING_INDEX(courses, ' -', -1);
-- Eliminar la columna original si es necesario
ALTER TABLE courses
DROP COLUMN courses;
SELECT * FROM courses;
-- No lo hago por si acaso, vemos más adelante

-- DESCRIPTION:
SELECT * FROM description;

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
SELECT schools.school_id, schools.school, badges.badges_id 
FROM schools 
LEFT JOIN badges ON badges.school_id = schools.school_id;

ALTER TABLE badges RENAME TO schools_badges;
SELECT * FROM schools_badges;

-- create a table for the badges names:
CREATE TABLE badges_name (badges_name text) ;
INSERT INTO badges_name (badges_name)
SELECT DISTINCT schools_badges.name
FROM schools_badges;
ALTER TABLE badges_name
ADD badges_id INT PRIMARY KEY AUTO_INCREMENT;
SELECT * FROM badges_name;
SELECT * FROM schools_badges;
ALTER TABLE schools_badges 
DROP COLUMN badges_id, DROP COLUMN description, DROP COLUMN keyword; 
SELECT * FROM schools_badges;

#UPDATE schools_badges
#SET schools_badges.name = badges_name.badges_id
#FROM badges_name
#INNER JOIN badges_name ON badges_name.name = schools_badges.name;

ALTER TABLE schools_badges
ADD COLUMN badges_id INT;

SELECT * FROM badges_name;
SELECT * FROM schools_badges;

UPDATE schools_badges
JOIN badges_name ON schools_badges.name = badges_name.badges_name
SET schools_badges.badges_id = badges_name.badges_id;

ALTER TABLE schools
ADD COLUMN school_description TEXT;
describe schools;
describe description;

UPDATE schools
JOIN description
ON schools.school = description.name
SET schools.school_description = description.description ;
select * from schools;

select * from description;

UPDATE description
SET name = LOWER(REPLACE(name, ' ', '-'));
select * from description; 
UPDATE description
SET name = REPLACE(name, '-&-', ' ');

DROP TABLE descriptions;

ALTER TABLE comments
ADD COLUMN school_id BIGINT;

UPDATE comments
JOIN schools
ON schools.school = comments.school
SET comments.school_id = schools.school_id ;

ALTER TABLE comments 
DROP COLUMN school;

SELECT * FROM comments;