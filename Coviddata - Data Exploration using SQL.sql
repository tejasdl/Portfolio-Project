/*
Covid 19 Data Exploration 
*/


Select * 
From PortfolioProject..CovidDeaths
order by 3, 4

--Select * 
--From PortfolioProject..CovidVacc
--order by 3, 4

--Looking at the data which we're gonna start with
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Taking a look at total cases vs total deaths(Percent of deaths)

Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercent
From PortfolioProject..CovidDeaths
Where location like '%India%'
order by 1,2

--First case was reported on 30th Jan 2020 
--First death was seen on 11th march 2020



--Percentage of population got covid
Select location, date, total_cases, population, (total_cases / population)*100 as InfectedPopPerc
From PortfolioProject..CovidDeaths
Where location like '%India%'
order by 1,2


--Finding out countries with highest infection rate to population

Select continent, location, MAX(total_cases) as TopInfectionCount, population, Max((total_cases / population))*100 as PercentPoulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent, location, population
order by PercentPoulationInfected desc

--Finding out countries with highest death rate to population

Select continent, location, MAX(cast(total_deaths as int)) as TopDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent, location
order by TopDeathCount desc

--Breaking down on basis of continents

Select continent, MAX(cast(total_deaths as int)) as TopDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TopDeathCount desc


--Global numbers

 Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int)) / sum(new_cases))*100 as GlobalDeathPercent
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2




Select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacc vac
on dea.location = vac.location
and dea.date = vac.date


--Looking at the total poulation vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacc vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 1, 2


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) RollingVacc
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacc vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Use CTE

with PopVsVac(continent, location, date, population,new_vaccinations, RollingVacc)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) RollingVacc
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacc vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingVacc/Population) * 100
From PopVsVac


--Temp table


Drop table if exists #PercentPopVacc
Create Table #PercentPopVacc
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVacc numeric
)


Insert into #PercentPopVacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) RollingVacc
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacc vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVacc/Population) * 100
From #PercentPopVacc



--Creating view to store data for visualization


Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) RollingVacc
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacc vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
from PercentPopulationVaccinated