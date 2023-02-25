--DATA EXPLORATORY OF COVID CASES

--Testing whether Datasets were correctly imported
SELECT *
FROM CovidDeaths
ORDER BY 3,4;

SELECT *
FROM CovidVaccinations
ORDER BY 3,4;

--Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths 
ORDER BY 1, 2;

--Looking at Total cases vs Total Deaths specific to South Africa

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE LOCATION like '%South Africa%'
ORDER BY 1, 2;

--Percentage of the population which got covid South Africa

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
WHERE LOCATION like '%South Africa%'
ORDER BY 1, 2;

--Looking at Countries with Highest Infection Rate compared to population
--Reason why Continent is not null is added in query I noticed that Asia is listed as both continent and location

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

--Showing Countries with Highest Death Count per Population (because of Datatype of the column has been casted as integer)
--Reason why Continent is not null is added in query I noticed that Asia is listed as both continent and location

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Breaking it down by continent (because of Datatype of the column has been casted as integer)

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Global Numbers (New_deaths cast as an integer because of the column data type)

SELECT date, SUM(new_cases) AS total_cases, 
SUM(CAST(new_deaths as int)) AS total_deaths,
SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2

--SUM of it

SELECT SUM(new_cases) AS total_cases, 
SUM(CAST(new_deaths as int)) AS total_deaths,
SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null

ORDER BY 1,2

--JOIN QUERIES
--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

--ADDING NEW_VACCINATIONS IS NOT NULL COZ CERTAIN COLUMNS HAD NULL WHICH HAS NO VALUE

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
ORDER BY 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
ORDER BY 1,2,3

--USING CTE since you cannot use newly added column as aggregate

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Divided
FROM PopvsVac

--CREATING A TEMPORARY TABLE

CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
--ORDER BY 1,2,3


SELECT *, (RollingPeopleVaccinated/Population)*100 AS Divided
FROM #PercentagePopulationVaccinated

--CREATING A VIEW TO STORE DATA FOR VISULATION

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null AND vac.new_vaccinations is not null
--ORDER BY 2,3


--Testing the VIEW table

SELECT *
FROM PercentPopulationVaccinated

