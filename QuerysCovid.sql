select * 
from PortfolioProject..CovidVaccinations
WHERE location = 'Colombia'
ORDER BY 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
WHERE location = 'Colombia'
ORDER BY 2

select continent, location, date, total_cases, total_deaths,(CAST(total_deaths AS decimal)/CAST(total_cases AS decimal))*100 as DeathPercent
from PortfolioProject..CovidDeaths
WHERE location = 'Colombia'
ORDER BY 2

select SUM(CAST(new_cases AS decimal)) as NewCases, SUM(CAST(new_deaths AS decimal)) as NewDeaths
--,(CAST(total_deaths AS decimal)/CAST(total_cases AS decimal))*100 as DeathPercent
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS decimal)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date 
	AND dea.location = vac.location
where dea.location = 'Colombia'
order by 2,3

WITH PopvsVac (Continent, Location, Date, Population, New_Vacc, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS decimal)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.date = vac.date 
	AND dea.location = vac.location
where dea.location = 'Colombia'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentOfPeopleVaccinated
from PopvsVac

select continent, SUM(CAST(population as decimal)) as Population
, SUM(CAST(total_deaths AS decimal))as TotalDeathsPerContinent
--, (TotalDeathsPerContinent/Population)*100
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 1

WITH PopvsDeathsPerContinent (Continent, Location, Population, TotalDeathsPerContinent)
AS
(
select continent, location, population
, MAX(CAST(total_deaths AS decimal)) as TotalDeathsPerContinent
--, (TotalDeathsPerContinent/Population)*100
from PortfolioProject..CovidDeaths
where continent is not null
group by continent, location, population
--order by 1
)
select * , (TotalDeathsPerContinent/Population)*100
from PopvsDeathsPerContinent
order by Continent

select continent, location, population, MAX(CAST(total_deaths AS decimal))
from PortfolioProject..CovidDeaths 
where location = 'Colombia'
group by continent, location, population