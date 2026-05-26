-- SQL Project - Data Cleaning


-- Show table
SELECT * 
FROM world_layoffs.layoffs;

-- The following are steps we take to clean the data.
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove any blank(unnecessary) columns


-- Next, we create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE layoffs_staging
LIKE world_layoffs.layoffs;

SELECT * 
FROM world_layoffs.layoffs_staging;

-- Now, we populate it with the values from our original table.

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Now, we see the populated table
SELECT * 
FROM world_layoffs.layoffs_staging;

-- Check if we got all the rows from the original table
SELECT 
	COUNT(*) 
FROM world_layoffs.layoffs_staging;

-- Next, we try to identify duplicates

SELECT *,
	ROW_NUMBER() OVER(
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
	ROW_NUMBER() OVER(
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
 # The above query gives us the duplicates
 # It is always good practice to doublecheck the outcome of your query
 
SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Casper';
 
 # Next, we create a new table, with a new row (row_num) by which we can filter out the duplicates
 
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num`INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM world_layoffs.layoffs_staging2;

# Now, we populate the new table

INSERT INTO world_layoffs.layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
			PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging;

# Show the populated new table
SELECT *
FROM world_layoffs.layoffs_staging2;

# The following query shows the duplicates
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE row_num>1;

# We now delete the duplicates

DELETE
FROM world_layoffs.layoffs_staging2
WHERE row_num>1;

# See the whole table

SELECT *
FROM world_layoffs.layoffs_staging2;


-- STANDARDIZING DATA
# This is basically finding issues iin your data and fixing it.

#The first issue we shall fix is removing white spaces from the name of the companies
SELECT 
	company,
    TRIM(company)
FROM world_layoffs.layoffs_staging2;

# Now that we have cleaned the company name, we update it iin the table as follows

UPDATE world_layoffs.layoffs_staging2
SET company = TRIM(company);

# If we run the qury below, we notice the update
SELECT 
	company,
    TRIM(company)
FROM world_layoffs.layoffs_staging2;

# Next, we study the industry column
SELECT 
	DISTINCT(industry)
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

# We have rows that are the same thing but appear as different rows, i.e Crypto, Crypto Currency and CryptoCurrency

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry LIKE 'Crypto%';

# Update the table to show Crypto instead of the other 2 alternatives

UPDATE 	layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

# Now, we check the updated table
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry LIKE 'Crypto%';

# Next, we study the location column
SELECT 
	DISTINCT(location)
FROM world_layoffs.layoffs_staging2
ORDER BY location;

# The above looks pretty good

# Next, we study the country column
SELECT 
	DISTINCT(country)
FROM world_layoffs.layoffs_staging2
ORDER BY country;

# In the above query, we have 2 instance of United States. We now fix it.
SELECT 
	DISTINCT country,
    TRIM(TRAILING '.' FROM country)
FROM world_layoffs.layoffs_staging2
ORDER BY country;

# Next, we update the table

UPDATE 	layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


# Let us view our table
SELECT *
FROM world_layoffs.layoffs_staging2;

# We now format our date iin the right order and also the right data type
SELECT
	`date`,
    STR_TO_DATE(`date`, '%m/%d/%Y')
FROM world_layoffs.layoffs_staging2;

# Next, we update our table date
UPDATE world_layoffs.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')

ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN `date`DATE;

-- NULL VALUES OR BLANK VALUES

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT 
	*
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL
OR industry = '';

UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';
# Next we check the industry and see how to populate the null spaces e.g Airbnb

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM world_layoffs.layoffs_staging2 AS t1
JOIN world_layoffs.layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

# Next, we translate this to an update statement

UPDATE world_layoffs.layoffs_staging2 AS t1
JOIN world_layoffs.layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;


-- REMOVING BLANK (OR UNNECESSARY) COLUMNS

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# Since we hope to work with the data of laid off staff in the EDA, we simply delete columns that are null in both total_laid_off and percentage_laid_off

DELETE
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
 
# Next, we remove the row_num we created initially

ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;

# Now, our clean table
SELECT *
FROM world_layoffs.layoffs_staging2;
