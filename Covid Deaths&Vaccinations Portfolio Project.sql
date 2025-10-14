SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select the Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths in the United States 2020-2021
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at total cases vs total deaths in Iran 2020-2021
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Iran'
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of the population got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS pop_covid_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at countries with their highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infect_cases,
MAX((total_cases/population))*100 AS pop_covid_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY pop_covid_percentage DESC

--Shows countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC

--Breaks things down by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC

--Global numbers
--Per day
SELECT date, SUM(new_cases) AS total_global_cases, SUM(CAST(new_deaths as int)) AS total_golbal_deaths,
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS global_deaths_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 DESC

--In total
SELECT SUM(new_cases) AS total_global_cases, SUM(CAST(new_deaths as int)) AS total_golbal_deaths,
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS global_deaths_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2 DESC

--Inner join CovidDeaths table & CovidVactions
SELECT *
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
and dea.date = vac.date


--Looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeople_vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- Use CTE
WITH pop_vs_vac (continent, location,date, population, new_vaccinations, rollingpeople_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeople_vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3
)
SELECT *, (rollingpeople_vaccinated/population)*100 rollvaccinated_percentage
FROM pop_vs_vac

-- TEMP TABLE
DROP TABLE IF EXISTS #percentpopulation_vaccinated
CREATE TABLE #percentpopulation_vaccinated
(continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeople_vaccinated numeric
)
INSERT INTO #percentpopulation_vaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeople_vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

--SELECT *,(rollingpeople_vaccinated/population)*100 rollvaccinated_percentage
--FROM #percentpopulation_vaccinated
--ORDER BY 1,2,3

SELECT continent, location, population, MAX(rollvaccinated_percentage) maxvaccinated_percentage
FROM (SELECT *,(rollingpeople_vaccinated/population)*100 rollvaccinated_percentage
FROM #percentpopulation_vaccinated) AS sub
GROUP BY continent, location, population
ORDER BY MAX(rollvaccinated_percentage) DESC

-- Creating a view to store data for later visualizations
USE PortfolioProject
GO
CREATE VIEW population_vaccinated_percentage AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingpeople_vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
GO

