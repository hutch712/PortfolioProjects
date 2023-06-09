select *
from PortfolioProject..CovidDeaths
where continent is not NULL
--and location like 'Canada%'
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by location, date

-- Looking at Total Cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPct
from PortfolioProject..CovidDeaths
where location like 'United Stat%'
order by location, date

-- Looking at Population vs Total Cases and vs Total Deaths and calculates percentage of Population for each
select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationCases, total_deaths, (total_deaths/population)*100 as PercentageOfPopulationDeaths
from PortfolioProject..CovidDeaths
where location like 'United Stat%'
order by location, date

-- Looking at countries with highest infection rate compare to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageOfPopulationInfected
from PortfolioProject..CovidDeaths
--where location like 'United Stat%'
group by location, population
order by PercentageOfPopulationInfected desc

-- Looking at countries with highest death rate compare to population
select location, population, max(total_deaths) as HighestDeathCount, max((total_deaths/population))*100 as PercentageOfPopulationDeaths
from PortfolioProject..CovidDeaths
--where location like 'United Stat%'
group by location, population
order by PercentageOfPopulationDeaths desc

create view CountriesDeathCount as
-- Show countries in order of highest death count
select location, max(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'United Stat%'
where continent is not NULL
group by location
order by TotalDeathCount desc

-- Show regions by highest death count in descending order 
select location, max(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'United Stat%'
where continent is NULL
group by location
order by TotalDeathCount desc
GO

-- Show regions by total deaths in descending order as of latest date for that region
select cd.location, Cast(cd.total_deaths as int) as TotalDeaths, cd.date
from PortfolioProject..CovidDeaths cd
Inner Join 
		(select location, max(date) as LatestDate
		from PortfolioProject..CovidDeaths
		where continent is NULL
		group by location) as LocationMaxDate
	on cd.location = LocationMaxDate.location
	and cd.date = LocationMaxDate.LatestDate
group by cd.location, cd.total_deaths, cd.date
order by TotalDeaths desc
GO

-- Show regions by total deaths in descending order as of latest date for that region (using CTE)
WITH LocationMaxDate2 as
(
	select location, max(date) as LatestDate
	from PortfolioProject..CovidDeaths
	where continent is NULL
	group by location
)

select cd.location, Cast(cd.total_deaths as int) as TotalDeaths, cd.date
from PortfolioProject..CovidDeaths cd
Join LocationMaxDate2
	on cd.location = LocationMaxDate2.location
	and cd.date = LocationMaxDate2.LatestDate
group by cd.location, cd.total_deaths, cd.date
order by TotalDeaths desc
GO

create view ContinentDeathCount as
-- Showing continent death counts in descending order
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

select date, total_cases, new_cases
from PortfolioProject..CovidDeaths
where location like 'World%'
order by 1 desc


select sum(new_cases)
from PortfolioProject..CovidDeaths
where continent is not NULL


-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


-- get Pct Vaccinated using CTE
with PopvsVac (cont, loc, dt, pop, new_vac, rollingPplVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
)

select *, (rollingPplVac / pop) * 100 as PctVaccinated
from PopvsVac


-- get Pct Vaccinated using temp table
drop table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

select *, (RollingPeopleVaccinated / Population) * 100 as PctVaccinated
from #PercentPopulationVaccinated
order by Location, Date


-- create a view for Percent of the Population Vaccinated by Location
drop view PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL

select *, (RollingPeopleVaccinated / population) * 100 as PercentVaccinated
from PercentPopulationVaccinated
