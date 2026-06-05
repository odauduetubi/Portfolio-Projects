-- Exploratory Data Analysis

# Let us query the clean data

SELECT *
FROM world_layoffs.layoffs_staging2;

-- Next, we check the maximum number of laoffs and also tthe percentage of layoffs for each of the companies 
SELECT 
	MAX(total_laid_off),
    MAX(percentage_laid_off)
FROM world_layoffs.layoffs_staging2;

# We see the list of companies that laid-off all their staff
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Next we check the companies that went under, ordering by those who raised funds (Some big companies)
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


# next we check the companies that let go of a lot of people

SELECT
	company,
	SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY `SUM(total_laid_off)` DESC;

-- Now, we check the date range
SELECT
	MIN(`date`), 
    MAX(`date`)
FROM world_layoffs.layoffs_staging2;


-- Next, we check what industry got hit the most.
SELECT
	industry,
	SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY `SUM(total_laid_off)` DESC;


-- Next, we check what country got hit the most.
SELECT
	country,
	SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY `SUM(total_laid_off)` DESC;

-- See the Year with highest total lay offs.
SELECT
	YEAR(`date`),
	SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC;

-- See the stage with highest total lay offs.
SELECT
	stage,
	SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

# Next, we do some rolling sum on the total lay offs

SELECT
	SUBSTRING(`date`, 1, 7) AS `MONTH`,
    SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY `MONTH` ASC;

WITH Rolling_Total AS
(SELECT
	SUBSTRING(`date`, 1, 7) AS `MONTH`,
    SUM(total_laid_off) AS total_off
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY `MONTH` ASC)
SELECT `MONTH`, 
total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Next, we see how many lay offs the companies are having per year
SELECT
	company,
    YEAR(`date`),
	SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

SELECT
	company,
    YEAR(`date`),
	SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Next, we try to rank them

WITH Company_Year(company, years, total_laid_off) AS
(SELECT
	company,
    YEAR(`date`),
	SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;

-- We now rank based off of the top 5 per year
WITH Company_Year(company, years, total_laid_off) AS
(SELECT
	company,
    YEAR(`date`),
	SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

