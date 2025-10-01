/*
Queries used for Tableau Project
*/

--.1 Global Numbers

SELECT SUM(new_cases) AS total_global_cases, SUM(CAST(new_deaths as int)) AS total_golbal_deaths,
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS global_deaths_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2 DESC


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


--.2 Total Deaths Per Continent

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--.3 Percent Population Infected Per Country

Select Location, Population, MAX(total_cases) as highest_infect_cases,  Max((total_cases/population))*100 as pop_covid_percentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by pop_covid_percentage desc


--.4 Percent Population Infected


Select Location, Population,date, MAX(total_cases) as highest_infect_cases,  Max((total_cases/population))*100 as pop_covid_percentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by pop_covid_percentage desc


