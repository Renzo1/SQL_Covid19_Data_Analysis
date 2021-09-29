-- Checking the coviddeaths columns

select *
from portfolioproject.coviddeaths
where continent <> location
order by 3, 4

-- QUERY 1: PART A
-- Showing Covid19 mortality rate at different countries
-- Showing the Total cases vs Total deaths
-- Showing the likelihood of dieing if you contract covid19 in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from portfolioproject.coviddeaths
where continent <> location and total_cases >= 10000
order by 1, 2;

-- QUERY 2:
-- Looking at Total cases vs Population
-- Shows what percentage of the population is infested by the virus
-- This also tells the possibility of contracting the virus in your country

select location, date, total_cases, total_deaths, (total_cases/population)*100 as Infected_Population_Percentage
from portfolioproject.coviddeaths
order by 1, 2


-- Query 3: 
-- Looking at countries currently with highest infected population percentage

select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Infected_Population_Percentage
from portfolioproject.coviddeaths
Group by location, Population
order by 4 DESC;


-- Query 4:
-- Showing countries with the highest deathcount per population

select location, MAX(total_deaths) as Total_Death_Count, MAX((total_deaths/population))*100 as Death_Count_Percentage
from portfolioproject.coviddeaths
where continent <> location
Group by location
order by 2 DESC;


-- Query 5: Lets look at the continental level
-- Showing continents with highest death counts

select location, MAX(total_deaths) as Total_Death_Count
from portfolioproject.coviddeaths
where continent = location
Group by continent
order by 2 DESC;

-- Query 6: Looking at the Global stats
-- Looking at the current Global infection and death rate

select MAX(date) as Latest_Date, SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as Death_Percentage
from portfolioproject.coviddeaths
where continent <> location
#group by date
order by 1;

-- Query 7:
-- Lets take a look at the CovidVaccitions table

select *
from portfolioproject.covidvaccinations
where continent <> location
order by 3, 4

-- Query 8:
-- Lets join the two data
-- Joining the two tables 
-- Joining them on date and location

select *
from portfolioproject.covidvaccinations dea
Join portfolioproject.coviddeaths vac
	on dea.location = vac.location
    and dea.date = vac.date;

-- Query 9:
-- Showing how many people in the world has been fully vaccinated by countries
-- Total Population vs Vaccinated Population

select dea.continent, dea.location, MAX(dea.date) as date, MAX(population) as Population, MAX(people_fully_vaccinated) as Total_Vaccinations,
MAX((people_fully_vaccinated/population)*100) as VaccinatedPopulationPerc
from portfolioproject.covidvaccinations dea
Join portfolioproject.coviddeaths vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent = dea.location
group by continent
order by 2,3;



-- Query 9: PART A
-- Showing how many people in the world has been fully vaccinated
-- Total Population vs Fully vaccinated Population

select dea.location, MAX(dea.date) as date, MAX(population) as WorldPopulation, MAX(people_fully_vaccinated) as VaccinatedPopulation, 
MAX((people_fully_vaccinated/population)*100) as PercOfVaccinatedPopulation
from portfolioproject.covidvaccinations dea
Join portfolioproject.coviddeaths vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent like '%world%'
group by dea.continent
order by 2, 3;

-- PART B 
-- The most vaccinated countries

select dea.location, MAX(dea.date) as date, MAX(population) as Population, MAX(people_fully_vaccinated) as VaccinatedPopulation, 
MAX((people_fully_vaccinated/population)*100) as PercOfVaccinatedPopulation
from portfolioproject.covidvaccinations dea
Join portfolioproject.coviddeaths vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> dea.location
group by dea.location
order by 4 DESC;


-- Query 10:
-- Showing the correlation between vaccinated population, New Cases, Total Case and Total Deaths
-- Using Temp table

select dea.location, dea.date as date, population as WorldPopulation, vac.new_cases, vac.total_cases, 
vac.total_deaths, people_fully_vaccinated , 
(people_fully_vaccinated/population)*100 as PercOfVaccinatedPopulation
from portfolioproject.covidvaccinations dea
Join portfolioproject.coviddeaths vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent like '%world%'
-- group by dea.continent
order by 2;


/*
Drop table if exists VaccinatedPopulationPerc;
Create	Table VaccinatedPopulationPerc
(
Continent VARCHAR(255),
location VARCHAR(255),
date VARCHAR(255),
Population BIGINT,
people_fully_vaccinated BIGINT
);
 
Insert into VaccinatedPopulationPerc
select dea.continent, dea.location, dea.date, population, people_fully_vaccinated
from portfolioproject.covidvaccinations dea
Join portfolioproject.coviddeaths vac
	on dea.location = vac.location
    and dea.date = vac.date
-- where dea.continent <> dea.location
order by 2,3;

select Location, date, Population, people_fully_vaccinated, (people_fully_vaccinated/population)*100 as PercOfVaccinatedPopulation
from VaccinatedPopulationPerc
where location like '%world%'
-- group by location
order by 5 DESC;
*/



/*
-- Query 9:
-- Showing how many people in the world has been vaccinated
-- Total Population vs Vaccinated Population

-- PART A
-- Deriving Total Vaccinations from the Cummulative Sum of New Vaccinations (CumVaccinatedPopulation)

select dea.continent, dea.location, dea.date, population, new_vaccinations,
SUM(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as CumVaccinatedPopulation
from portfolioproject.covidvaccinations dea
Join portfolioproject.coviddeaths vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> dea.location
order by 2,3;

-- PART B
-- Showing percentage of vaccinated people vs population in a country
-- Using Temp table

Drop table if exists VaccinatedPopulationPerc;
Create	Table VaccinatedPopulationPerc
(
Continent VARCHAR(255),
location VARCHAR(255),
date VARCHAR(255),
Population BIGINT,
New_vaccinations BIGINT,
CumVaccinatedPopulation BIGINT
);
 
Insert into VaccinatedPopulationPerc
select dea.continent, dea.location, dea.date, population, new_vaccinations,
SUM(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as CumVaccinatedPopulation
from portfolioproject.covidvaccinations dea
Join portfolioproject.coviddeaths vac
	on dea.location = vac.location
    and dea.date = vac.date
-- where dea.continent <> dea.location
order by 2,3;

select Location, MAX(date), MAX(Population), MAX(CumVaccinatedPopulation), MAX((CumVaccinatedPopulation/population)*100) as VaccinatedPopulationPerc2
from VaccinatedPopulationPerc
where continent <> location
group by location
order by 5 DESC;
*/

