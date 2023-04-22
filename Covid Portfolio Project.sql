--Covid Deaths and covid vaccination table

select * from
PortfolioProject..CovidDeaths

select * from
PortfolioProject..CovidVaccinations


select location, date, total_cases, total_deaths,COALESCE(total_deaths / NULLIF(total_cases,0), 0)*100 as DeathPercentage
from
PortfolioProject..CovidDeaths
order by 1,2


-- Death percentage

select location, date, total_cases, total_deaths,(cast(total_deaths as float) / cast(total_cases as float))*100 as DeathPercentage
from
PortfolioProject..CovidDeaths
order by 1,2

--Total case vs population


select location, date, total_cases, population,cast(total_cases as float) / cast(population as float)*100 as CasePercentage
from
PortfolioProject..CovidDeaths
order by 1,2


--looking at countries with highest infection rate compared to population.

select location,population,MAX(total_cases) as HighestInfectionCount, cast(total_cases as decimal)/ cast(population as decimal)*100 as PopulationInfected
from
PortfolioProject..CovidDeaths
group by location, population, total_cases
order by 1,2


---showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from
PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--grouping by continents

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from
PortfolioProject..CovidDeaths
where continent is   null
and location not like '%income%'
group by location
order by TotalDeathCount desc

--global numbers



select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,COALESCE(SUM(cast(new_deaths as int)) / NULLIF(SUM(new_cases),0), 0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) as RollingCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


---with CTE

with PopvsVac(continent, location,date, Population, New_vaccinations, RollingCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) as RollingCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingCount/Population)*100
from PopvsVac



--Temp Table

create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingCount numeric
)

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) as RollingCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


select * from  PercentPopulationVaccinated

---creating view to store data for later visualizations

create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) over  (partition by dea.location order by dea.location, dea.date) as RollingCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


