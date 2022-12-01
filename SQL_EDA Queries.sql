/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- select data that we are going to stating with 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeaths
where continent is not null
order by 2,3;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
order by 1,2;

-- Countries with Highest Infection Rate compared to Population 

select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
group by location, Population
order by PercentPopulationInfected desc;

-- countries with Highest Death count per Population

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by location
order by totalDeathCount desc

--Breaking things down by continent 
-- showing continents with the highest death count per population

Select continent, Max(Cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.. covidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Global Numbers
Select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(CAST(NEW_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

-- Sum of total cases vs total deaths and percentage

Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(CAST(NEW_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2;

-- Covid_vaccinations
select * 
from PortfolioProject..covidVaccinations; 

-- Join death and vaccinations 
select * 
from PortfolioProject..covidDeaths dea
Join PortfolioProject..covidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date;

-- looking at total population vs vaccation 
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
  on dea.date = vac.date
  and dea.location = vac.location
where dea.continent is not null
order by 1,2,3; 

-- Window functions 
set statistics time,io on;

-- USE CTE as we cannot manupliate the column we just created so we can either create CTE or TEMP table 
with PopvsVac ( continent,location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
-- ( RollingPeopleVAccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
  on dea.date = vac.date
  and dea.location = vac.location
--where dea.continent is not null
--order by 2,3
) 

select *, (RollingPeopleVAccinated/population)*100
from PopvsVac 

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentsPopulationVaccinated
create table #PercentsPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert Into #PercentsPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations 
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
-- ( RollingPeopleVAccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
  on dea.date = vac.date
  and dea.location = vac.location
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100 as RollingPercentage
from #PercentsPopulationVaccinated

-- Creating view to store data for late visualizations 
Create View PercentsPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-- Creating View total cases gobally 
create view GlobalCasesDeath as
Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(CAST(NEW_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
--order by 1,2;

-- call the view 
select * 
from GlobalCasesDeath;
























--




