

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
Order by 3,4

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
Order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths 

SELECT location, date, total_cases, total_deaths,(CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases), 0))* 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
Order by 1,2

--Looking at Total Cases vs Population 
--Shows percentage of population got Covid
SELECT location, date, total_cases, population,(CONVERT(float, total_cases)/ (population)) * 100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
Order by 1,2

--Countries with Highest Infection Rate compared to population 

SELECT location,population, MAX (CAST (total_cases as int)) as HighestInfectionCount
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
--WHERE location like '%states%'

--Showing countries with Highest Death count per population

SELECT location, MAX (CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
Order by TotalDeathCount desc


--Showing the continents with the highest death count

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
Order by TotalDeathCount desc

--Global numbers 
--we could take total_cases but totalcases is i nvarchar and to find its sum we have to convert it so we took new_cases instead
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/ NULLIF(SUM(new_cases),0)*100 as TotalDeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
Order by 1,2

--USE CTE 
--Looking at Total Population vs Vaccinations

WITH PopvsVac
(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentagePopulationVaccinated
FROM PopvsVac
--Order by 2,3

 

--Temp tables
DROP Table if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentagePopulationVaccinated
FROM #PercentagePopulationVaccinated

--creating view to store data for later visualizations


CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

DROP VIEW PercentagePopulationVaccinated

Select *
FROM PercentagePopulationVaccinated
