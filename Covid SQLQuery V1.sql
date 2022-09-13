-- We have two tables
--1st table CovidDeath

select *
from PortfolioProject1..CovidDeath
where continent is not null

--2nd Table CovidVaccination

select *
from PortfolioProject1..CovidVaccination
where continent is not null



-- Selecting data that we are going to be using

select location,date,total_cases,new_cases, total_deaths, population
from PortfolioProject1..CovidDeath
where continent is not null
order by 1,2

--Total Case vs Total Death
--Likelyhood of death by country

select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeath
--where location='Canada'
where continent is not null
order by 1,2 Desc


--Total Cases vs Population
--Percentage of population Got in covid
select location,date,population, total_cases, (total_cases/population)*100 as InfecioinPercentage
from PortfolioProject1..CovidDeath
where location='India'and continent is not null
order by 1,2 Desc

-- Countries Highest infection rate compare to population
select location, population, MAX(total_cases) as HightInfectionCount, max((total_cases/population))*100 as PercetPopulationInfected
from PortfolioProject1..CovidDeath
--where location='India'
where continent is not null
group by location,population
order by 4 desc

--Countries hight death count by population

select location, population, MAX(cast(total_deaths as int)) as HightDeathCount, max((cast(total_deaths as int)/population))*100 as PercetPopulationDied
from PortfolioProject1..CovidDeath
--where location='India'
where continent is not null
group by location,population
order by 3 desc

--Do same thing by Continent
--Showing the continent with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as HightDeathCount, max((cast(total_deaths as int)/population))*100 as PercetPopulationDied
from PortfolioProject1..CovidDeath
--where location='India'
where continent is not null
group by continent--,population
order by 3 desc

--GLOBAL NUMBERS

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
from PortfolioProject1..CovidDeath
--where location='Canada'
where continent is not null
Group by date
order by 4 desc



--Let's Use another Table
select *
from PortfolioProject1..CovidVaccination

--Join this two table
select *
from PortfolioProject1..CovidDeath death
join PortfolioProject1..CovidVaccination vacc
	on death.location = vacc.location
	and death.date = vacc.date


-- Total Population vs Vacciation

select death.continent,death.location, death.date, death.population, vacc.new_vaccinations
from PortfolioProject1..CovidDeath death
join PortfolioProject1..CovidVaccination vacc
	on death.location = vacc.location
	and death.date = vacc.date
	where death.continent is not null
	and death.location='Canada'
order by 2, 3


-- Total Vaccination vs population (increatmental)


select death.continent,death.location, death.date, death.population, vacc.new_vaccinations, SUM(CONVERT(int,vacc.new_vaccinations)) 
OVER (Partition by death.location order by death.location, death.date) as IncreasingVaccinationNumber
from PortfolioProject1..CovidDeath death
join PortfolioProject1..CovidVaccination vacc
	on death.location = vacc.location
	and death.date = vacc.date
	where death.continent is not null
	and death.location='Canada'
order by 2, 3


--Using CTE
with PopvsVacc (Continent, Location, date, population, new_vaccination, IncreasingVaccinationNumber)
as
(
select death.continent,death.location, death.date, death.population, vacc.new_vaccinations, SUM(CONVERT(int,vacc.new_vaccinations)) 
OVER (Partition by death.location order by death.location, death.date) as IncreasingVaccinationNumber
from PortfolioProject1..CovidDeath death
join PortfolioProject1..CovidVaccination vacc
	on death.location = vacc.location
	and death.date = vacc.date
	where death.continent is not null
	and death.location='Canada'
--order by 2, 3
)
select *, (IncreasingVaccinationNumber/population)*100 as InVacNumberPersentage
from PopvsVacc

-- Using Temp Table

Drop table if exists #PersentPopulationVaccninated
Create Table #PersentPopulationVaccninated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	IncreasingVaccinationNumber numeric
)

insert into #PersentPopulationVaccninated
select death.continent,death.location, death.date, death.population, vacc.new_vaccinations, SUM(CONVERT(int,vacc.new_vaccinations)) 
OVER (Partition by death.location order by death.location, death.date) as IncreasingVaccinationNumber
from PortfolioProject1..CovidDeath death
join PortfolioProject1..CovidVaccination vacc
	on death.location = vacc.location
	and death.date = vacc.date
	where death.continent is not null
	and death.location='Canada'
order by 2, 3

select *, (IncreasingVaccinationNumber/population)*100 as InVacNumberPersentage
from #PersentPopulationVaccninated

-- Creating View to store data for later visialyzation

drop view if exists PersentPopulationVaccninated

Create view PersentPopulationVaccninated1 as
Select death.continent,death.location, death.date, death.population, vacc.new_vaccinations, SUM(CONVERT(int,vacc.new_vaccinations)) 
OVER (Partition by death.location order by death.location, death.date) as IncreasingVaccinationNumber
from PortfolioProject1..CovidDeath death
join PortfolioProject1..CovidVaccination vacc
	on death.location = vacc.location
	and death.date = vacc.date
	where death.continent is not null
	and death.location='Canada'
--order by 2, 3

select *
from PersentPopulationVaccninated1