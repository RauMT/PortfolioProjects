
/* 

Exploration WorldWide Covid-19 Data (01-01-2020/30-04-2021)

Skill Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types 

*/

--Show Data CovidDeaths per country without continent
SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Show Data CovidVaccinations per country without continent

SELECT *
FROM PortfolioProject1..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject1..CovidVaccinations
--ORDER BY 3,4

-- Select the Data that we are going to use first

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject1..CovidDeaths 
ORDER BY 1,2

-- Total Cases vs Total Deaths per Country (Netherlands)
	-- Shows the death percentage per day during the whole period
	-- Shows the likelyhood of dying when infected with Covid-19 per country

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths 
WHERE location like 'Net%'
ORDER BY 1,2

-- Total Cases vs Population
	-- Shows the percentage of the population infected by Covid-19 
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject1..CovidDeaths 
WHERE location like 'Neth%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population

SELECT Location, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS  InfectedPercentage
FROM PortfolioProject1..CovidDeaths 
GROUP BY Location, population 
ORDER BY InfectedPercentage desc

-- Countries with highest death rate per country

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Countries with highest death rate per population

SELECT Location, population, MAX(cast(total_deaths as int)) AS HighestDeathCount , MAX((Total_deaths / population))*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths 
GROUP BY Location, Population
ORDER BY DeathPercentage desc

-- LET'S LOOK AT THIS BY CONTINENT
 
-- Showing country per continent with highest death count per population

SELECT continent, location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY TotalDeathCount desc

-- Showing continents with highest death count per population 

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- GlOBAL NUMBERS
	-- Using SUM on new cases gives us the total new cases per day, same for new death cases per day

SELECT date, SUM(new_cases) AS total_new_cases, SUM(cast(new_deaths as int)) AS total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 AS DeathRatioNewCasesDeaths
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2

SELECT date, SUM(total_cases) AS total_cases, SUM(cast(total_deaths as int)) AS total_deaths, SUM(new_cases) AS total_cases_perday, SUM(cast(new_deaths as int)) AS total_deaths_perday, SUM(cast(total_deaths as int))/SUM(total_cases)* 100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2

-- Total Cases And Deaths WorldWide

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date 
ORDER BY 1,2


-- Total Population vs Vaccinations
	-- Shows the percentage of population that has received at least one Covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
--  , (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
	-- Using CTE to perform Calculation on Partition By in previous query

-- Vaccination And VaccinationRate per Country

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
--  , (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinationRate
FROM PopvsVac
ORDER BY 2,3


-- TEMP TABLE 
	---- Using Temp Table to perform Calculation on PARTITION BY in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric 
)

INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
--  , (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 

SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinationRate
FROM #PercentPopulationVaccinated
ORDER BY 2,3




-- Creating Views to store Data for later visualization
	-- Had to use USED for it to work, as the view did not render in the correct project by itself
USE PortfolioProject1

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
--  , (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3 

SELECT * 
FROM PercentPopulationVaccinated

-- Create more views to use 



