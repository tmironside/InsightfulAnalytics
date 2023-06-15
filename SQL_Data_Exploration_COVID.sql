Select *
From CovidProject..CovidDeaths
Order by 3,4

Select *
From CovidProject..CovidVaccinations
Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as death_percentage
From CovidProject..CovidDeaths
order by 1,2

--Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as case_percentage
From CovidProject..CovidDeaths
order by 1,2

--Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectedPercentage
From CovidProject..CovidDeaths
Group by Location, population
order by PopulationInfectedPercentage desc

--Countries with Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by Location, population
order by TotalDeathCount desc

--Continents with Highest Death Count

Select continent, MAX(total_deaths) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage 
From CovidProject..CovidDeaths
Where continent is not null
Group by date
order by date

--Total Global Numbers 

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage 
From CovidProject..CovidDeaths
Where continent is not null
order by 1,2

--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(ISNULL(CAST(vac.new_vaccinations as bigint), 0)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1, 2, 3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(ISNULL(CAST(vac.new_vaccinations as bigint), 0)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(ISNULL(CAST(vac.new_vaccinations as bigint), 0)) 
 OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(ISNULL(CAST(vac.new_vaccinations as bigint), 0)) 
 OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated