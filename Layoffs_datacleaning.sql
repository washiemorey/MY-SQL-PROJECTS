# Data Cleaning
select * from layoffs;

#Cleaning steps 
-- 1. Remove duplicates if any
-- 2. Standadise values
-- 3 . Check Null values or blank values
-- 4.Remove unneccesary columns

# Creating new table similar to initial layoffs table for cleaning procces 
create table layoffs_staging like layoffs;
select * from layoffs_staging;
#Inserting table values 
insert layoffs_staging select * from layoffs;
select * from layoffs_staging;

#...............REMOVING DUPLICATES FROM THE DATA
#Checking for duplicates 
select * ,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,date,
stage,country,funds_raised_millions) as RowNumber   #Partitioning through rows to check duplicates 
from layoffs_staging;

with duplicate_cte as (     #Extracting duplicate rows 
select * ,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,date,
stage,country,funds_raised_millions) as RowNumber
from layoffs_staging)
select * from
duplicate_cte
where RowNumber > 1;

select * from  #Confirming that Yahoo is duplicate
layoffs_staging
where Company = "Yahoo";


#Creating new table to remove duplivate rows 
CREATE TABLE `layoffs_staging2` (
  `company` text DEFAULT NULL,
  `location` text DEFAULT NULL,
  `industry` text DEFAULT NULL,
  `total_laid_off` int(11) DEFAULT NULL,
  `percentage_laid_off` text DEFAULT NULL,
  `date` text DEFAULT NULL,
  `stage` text DEFAULT NULL,
  `country` text DEFAULT NULL,
  `funds_raised_millions` int(11) DEFAULT NULL,
  `RowNumber` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

select * from layoffs_staging2;

insert  layoffs_staging2 
select *,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,date,
stage,country,funds_raised_millions) as RowNumber   #Partitioning through rows to check duplicates 
from layoffs_staging;

#Selecting duplicate rows in the table
select * from layoffs_staging2
where RowNumber >1;


#Deleting duplicate rows
SET SQL_SAFE_UPDATES = 0;

delete  from layoffs_staging2
where RowNumber >1;

select * from layoffs_staging2;

select * from  #Just confirming that Yahoo is not duplicate
layoffs_staging2
where Company = "Yahoo";

#Counting total number of rows in original table and on table that duplicates have been removed
select count(*) from layoffs;
select count(*) from layoffs_staging2;

#................STANDADIZING THE DATA 
#Company
select Company,trim(Company) from layoffs_staging2;

update layoffs_staging2
set Company = trim(Company);

#Industry
select distinct industry from layoffs_staging2   #Selecting unique industries and Identifying ones to be merged 
order by 1;

select * from layoffs_staging2   #Selecting industries with name crypto and merging them to one 
where industry like "crypto%";

update layoffs_staging2
set industry = "Crypto"
where industry like "crypto%";

select distinct industry from layoffs_staging2   #Confirming that crypto is merged
order by 1;

#...Location
select distinct location from layoffs_staging2   #Selecting unique locations and Identifying ones to be merged 
order by 1;

#...Country
select distinct country from layoffs_staging2   #Selecting unique countries and Identifying ones to be merged 
order by 1;

update layoffs_staging2
set country = "United States"
where country = "United States.";

#....Date    
select date ,             #Converting data into its correct format 
str_to_date(date,"%m/%d/%Y") 
from layoffs_staging2;

update layoffs_staging2  #Changing date format fromstring to date
set date = str_to_date(date,"%m/%d/%Y");

alter table layoffs_staging2
modify column date  date;

#Percentage laid off
alter table layoffs_staging2  #Converting percentage laid off the correct format from text to decimal
modify column percentage_laid_off decimal(10,3);
select * from layoffs_staging2;


#..............CHECKING FOR NULL VALUES
select * from layoffs_staging2
where percentage_laid_off is Null
and total_laid_off is Null;

#Cheking null and blank values in Industry column and populating them
select  * from 
layoffs_staging2
where industry is null
or 
industry = " ";

select  * from 
layoffs_staging2
where company = "Airbnb";

update layoffs_staging2
set industry = Null
where industry = " ";

select * from 
layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
where (t1.industry is null )
and( t2.industry is not null or t2.industry =! " ");

set sql_safe_updates = 0;
update 
layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null)
and( t2.industry is not null or t2.industry =! " ");


#Removing rows with both percentage laid off and total laid off as Null
select * from layoffs_staging2
where percentage_laid_off is Null
and total_laid_off is Null;

delete from  layoffs_staging2
where percentage_laid_off is Null
and total_laid_off is Null;

#Checking for Null and blank values in Company column
select distinct company 
from layoffs_staging2
where company = " "
or company is Null;

#Checking for Null and blank values in Location column
select distinct location 
from layoffs_staging2
where location is Null
or location = " ";

#Checking for Null and blank values in Date  column
select * 
from layoffs_staging2
where date is Null
or date = " ";

#Deleting Null row with Null date from the data
delete 
from layoffs_staging2
where date is Null;

#Checking for Null and blank values in stage  column
select * 
from layoffs_staging2
where stage is Null
or stage = " ";

#Checking for Null and blank values in Country  column
select * 
from layoffs_staging2
where country is Null
or country = " ";

#Removing RowNumber column
select * from layoffs_staging2;

alter table layoffs_staging2
drop column RowNumber;

