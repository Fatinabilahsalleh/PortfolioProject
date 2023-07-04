
SELECT *
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	ORDER BY 3,4

--SELECT *
--	FROM PortfolioProject..CovidVaccinations
--	ORDER BY 3,4

-- Select Data that we are going to be using
SELECT 
	Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country
SELECT 
	Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Malaysia%'
ORDER BY 1,2

-- Total Cases VS Population
-- Percentage of population got Covid
SELECT 
	Location, date, total_cases, Population, total_deaths, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Malaysia%'
ORDER BY 1,2

-- Country highest infection rates compared to population
SELECT 
	Location, Population, MAX(total_cases) as HighestInfectionCountry, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

-- Country Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Break things down by continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

-- BY Date
SELECT 
	date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as  total_death, SUM(cast(new_deaths as int))/SUM(new_cases)  as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Malaysia%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2
 

 -- Death Percentage All of the world
SELECT
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as  total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Malaysia%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2

-- JOIN TWO TABLE ON DATE AND LOCATION
-- Total Population VS Vacc

SELECT 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND  dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--new vaccination per day
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND  dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--if we want to calculate new vaccinations per day vs population, we ned to do cte / temp table. 
--because you can do operation on the new column you just created

-- USE CTE

WITH PopvsVac (Continent, location, Date, Population, New_vaccinations, RollingPeopleVaccinated) as
(
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND  dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND  dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND  dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated