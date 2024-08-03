-- Select all data from CovidDeaths where the continent is not null
-- Order by location and date

SELECT *
FROM ProfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY Location, Date;

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country

SELECT Location, Date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM ProfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY Location, Date;

-- Total Cases vs Population
-- Shows what percentage of the population was infected with COVID

SELECT Location, Date, Population, total_cases, 
       (total_cases / population) * 100 AS PercentPopulationInfected
FROM ProfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY Location, Date;

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, 
       MAX(total_cases) AS HighestInfectionCount,  
       MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM ProfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count per Population

SELECT Location, 
       MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Showing continents with the highest death count per population

SELECT continent, 
       MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM ProfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Total Population vs Vaccinations
-- Shows the percentage of the population that has received at least one COVID vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM ProfolioProject..CovidDeaths dea
JOIN ProfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY dea.location, dea.date;

-- Using CTE to perform calculation on PARTITION BY in the previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM ProfolioProject..CovidDeaths dea
    JOIN ProfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;

-- Using Temp Table to perform calculation on PARTITION BY in the previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TABLE PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM ProfolioProject..CovidDeaths dea
JOIN ProfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM ProfolioProject..CovidDeaths dea
JOIN ProfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
