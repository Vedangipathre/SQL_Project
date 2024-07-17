--Select *
--From ProfolioProject..CovidDeaths
--Where continent is not null 
--order by 3,4


--loook for total cases vs total deaths
--tell us percent of you dying if you get covid at a particular year

--SELECT Location, date, total_cases,total_death,(total_deaths/total_cases)
--FROM ProfolioProject..CovidDeaths
--WHERE location like '%asia%'
--order by 1,2

--SELECT Location, date, total_cases,population,(total_cases/population)*100 as death_percent
--FROM ProfolioProject..CovidDeaths
--WHERE location like '%asia%'
--order by 1,2

--look for countries  with highest infection rate compare to pop.
--SELECT Location, date, MAX(total_cases) AS HIGHESTINFECTIONCOUNT,population,MAX((total_cases/population))*100 as PERCENTAGEPOPINFECTED
--FROM ProfolioProject..CovidDeaths

--order by 1,2

-- Select Data that we are going to be starting with

--Select Location, date, total_cases, new_cases, total_deaths, population
--From ProfolioProject..CovidDeaths
--Where continent is not null 
--order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From [ProfolioProject]..CovidDeaths
--Where location like '%asia%'
--and continent is not null 
--order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

--Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
--From ProfolioProject..CovidDeaths
----Where location like '%asia%'
--order by 1,2

-- Countries with Highest Infection Rate compared to Population
--Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
--From [ProfolioProject]..CovidDeaths
----Where location like '%states%'
--Group by Location, Population
--order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

--Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
--From ProfolioProject..CovidDeaths
----Where location like '%states%'
--Where continent is not null 
--Group by Location
--order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

--Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
--From ProfolioProject..CovidDeaths
----Where location like '%states%'
--Where continent is not null 
--Group by continent
--order by TotalDeathCount desc

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProfolioProject..CovidDeaths dea
Join ProfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



