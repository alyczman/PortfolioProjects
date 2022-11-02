-- COVID SQL Exploration

SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--order by 3,4


-- Select Data that we're going to be using

SELECT Location, date, total_cases, new_cases,total_deaths,population
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
order by 1,2

-- Look at total cases vs total deaths
-- Shows the likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null AND location like '%states%'
order by 1,2

-- Total cases vs. population
-- shows what percentage of population got COVID

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PopInfected
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
Group by location, population
order by PopInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is null
--WHERE location like '%states%'
Group by location
order by TotalDeathCount desc

-- Showing countries with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
Group by continent
order by TotalDeathCount desc

-- Showing the continents with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
Group by continent
order by TotalDeathCount desc

-- Global numbers
-- use aggregate functions to avoid grouping by everything

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
--group by date
order by 1,2

-- Join both datasets, look at total pop vs vaccinations

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingVax)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVax
--, (RollingVax/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
SELECT *, (RollingVax/Population)*100
FROM PopvsVac



-- TEMP TABLE

Drop Table if exists #PercentPopulationVax
Create Table #PercentPopulationVax
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingVax numeric,
)

Insert into #PercentPopulationVax
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVax
--, (RollingVax/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

SELECT *, (RollingVax/Population)*100
FROM #PercentPopulationVax


-- Create a Views to store for visualizations

Create View PercentPopVax as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVax
--, (RollingVax/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select *
FROM PercentPopVax