SELECT *
FROM PortfolioProject ..CovidDeaths
ORDER BY 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject ..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject ..CovidDeaths
WHERE location like '%Philippines%'
ORDER BY 1,2


-- Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject ..CovidDeaths
WHERE location like '%Philippines%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population


SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS CasesPercentage
FROM PortfolioProject ..CovidDeaths
--WHERE location like '%Philippines%'
GROUP BY location, population
ORDER BY CasesPercentage DESC


-- Showing the Countries with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject ..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Breakdown of highest death count per continent

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject ..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Alternate

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjecNULLt ..CovidDeaths
WHERE continent is 
GROUP BY location
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, 
		SUM(CAST(new_deaths AS INT)) AS total_deaths, 
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deathpercentage --, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject ..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Joining CovidDeaths and CovidVaccinations tables

SELECT *
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- Looking at Total Population vs Vaccinations

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingVaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
    --AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3

-- USE CTE

;WITH PopvsVac(continent, location, date, population, new_vaccinations, rollingVaccinations)
AS
(
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingVaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
    --AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rollingVaccinations/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric,
)
INSERT INTO PercentPopulationVaccinated
SELECT *, (rollingVaccinations/population)*100
FROM #PercentPopulationVaccinated 


Insert into
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingVaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
    --AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3

-- Create View to store data for later visualizations

CREATE VIEW PercentPopulation AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingVaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
    --AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3