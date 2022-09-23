--Select all imported data to ensure that it all looks how it did in excel--
SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null;
SELECT *
FROM PortfolioProject..CovidVaccinations$

--Selecting the information I will be using--
SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2;

--DATA CLEANING--
--Some of the columns are the wrong data type--
ALTER TABLE CovidDeaths$
ALTER COLUMN total_deaths float;

ALTER TABLE CovidDeaths$
ALTER COLUMN date date;

ALTER TABLE CovidDeaths$
ALTER COLUMN total_cases float;

ALTER TABLE CovidDeaths$
ALTER COLUMN new_cases float;

ALTER TABLE CovidDeaths$
ALTER COLUMN population float;

ALTER TABLE CovidVaccinations$
ALTER COLUMN new_tests float;

ALTER TABLE CovidVaccinations$
ALTER COLUMN total_tests float;

ALTER TABLE CovidVaccinations$
ALTER COLUMN total_vaccinations float;

ALTER TABLE CovidVaccinations$
ALTER COLUMN new_vaccinations float;


--DATA EXPLORATION--
--CovidDeaths$ table--
--Total cases vs total deaths (death rate for people who had covid)(basic calculation)--
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2;
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%State%'
ORDER BY 1,2;

--Total cases vs population (percent of population that had covid)--
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_rate
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2;
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_rate
FROM PortfolioProject..CovidDeaths$
WHERE location like '%State%'
ORDER BY 1,2;

--Looking at countries with the highest infection rates--
SELECT location, population, MAX(total_cases) AS highest_total_cases, MAX((total_cases/population))*100 AS infection_rate
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY infection_rate desc;

--Looking at Countries' death count by population--
SELECT location, population, MAX(total_deaths) AS death_count
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY population desc;

--Looking at which countries have the highest death rates--
SELECT location, population, MAX(total_deaths) AS highest_total_deaths, MAX((total_deaths/population))*100 AS death_rate
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY death_rate desc;

--Looking at stats by continent rather than country--
SELECT location, MAX(total_deaths) AS highest_total_deaths
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY highest_total_deaths desc;

--Global death rate--
SELECT SUM(new_cases) AS total_cases_globally, SUM(CAST(new_deaths as float)) AS total_deaths_globally, SUM(CAST(new_deaths as float))/SUM(CAST(new_cases AS float))*100 AS death_rate_globally
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1 desc;

--Join tables code--
SELECT * 
FROM PortfolioProject..CovidDeaths$
JOIN PortfolioProject..CovidVaccinations$
ON CovidDeaths$.location = CovidVaccinations$.location and CovidDeaths$.date = CovidVaccinations$.date;

--CovidVaccinations$ table--
--total population and vaccinations--
WITH Population_Vaccinated (continent, location, date, population, new_vaccinations, total_new_vaccinations)
AS (
SELECT CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccinations$.new_vaccinations, SUM(CAST(CovidVaccinations$.new_vaccinations AS int)) OVER (PARTITION BY CovidDeaths$.location ORDER BY CovidDeaths$.location, CovidDeaths$.date) AS total_new_vaccinations
FROM PortfolioProject..CovidDeaths$
JOIN PortfolioProject..CovidVaccinations$
ON CovidDeaths$.location = CovidVaccinations$.location and CovidDeaths$.date = CovidVaccinations$.date
WHERE CovidDeaths$.continent is not null
)
SELECT *, (total_new_vaccinations/population)*100 AS percent_vaccinated
FROM Population_Vaccinated

--Create CTE for above query--
WITH Population_Vaccinated (continent, location, date, population, total_new_vaccinations)
AS 

--Create view for future visualizations--
CREATE VIEW percent_vaccinated
AS
SELECT CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccinations$.new_vaccinations, SUM(CAST(CovidVaccinations$.new_vaccinations AS int)) OVER (PARTITION BY CovidDeaths$.location ORDER BY CovidDeaths$.location, CovidDeaths$.date) AS total_new_vaccinations
FROM PortfolioProject..CovidDeaths$
JOIN PortfolioProject..CovidVaccinations$
ON CovidDeaths$.location = CovidVaccinations$.location and CovidDeaths$.date = CovidVaccinations$.date
WHERE CovidDeaths$.continent is not null;