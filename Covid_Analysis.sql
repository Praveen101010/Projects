SELECT * FROM ['Covid_deaths'] 
WHERE continent is NOT NULL
order by 3,4

SELECT * FROM ['Covid_vacc$'] 

--SELECT Data that we are going to be using
SELECT Location, date, Total_cases, new_cases, total_deaths, Population
FROM ['Covid_deaths']
WHERE continent is NOT NULL
order by 1,2

--Looking at total cases vs total deaths
--showa likelihood of dying if you get covid in India
SELECT Location, date, Total_cases, total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM ['Covid_deaths']
Where Location Like '%India%' AND  continent is NOT NULL
order by 1,2

--looking at total cases vs percentage
--Shows what percentage of population got covid
SELECT Location, date, Total_cases, total_deaths,Population,(total_cases/Population)*100 AS Percentage_cases 
FROM ['Covid_deaths']
Where Location Like '%India%' AND  continent is NOT NULL
order by 1,2

--looking at country with highest infection rate compared to population
SELECT Location, Population, MAX(Total_cases) AS highestinfectionCount,Max((total_deaths/total_cases)*100) AS Percentpopulationinfected
FROM ['Covid_deaths']
--Where Location Like '%India%'
WHERE continent is NOT NULL
Group By location, Population
order by Percentpopulationinfected DESC

--showing the countries with highest death count per population
SELECT Location, MAX(Cast(Total_deaths as int)) AS totaldeaths
FROM ['Covid_deaths']
--Where Location Like '%India%'
WHERE continent is NOT NULL
Group By location
order by totaldeaths DESC

--let's break things down by continent
--showing continents with the highest covid death counts
SELECT location, MAX(Cast(Total_deaths as int)) AS totaldeaths
FROM ['Covid_deaths']
--Where Location Like '%India%'
WHERE continent is  NULL
Group By location
order by totaldeaths DESC

--global numbers
SELECT date, SUM(new_cases) as totalcases,
       SUM(cast(new_deaths as int)) AS totaldeaths,
	   SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
FROM ['Covid_deaths']
WHERE CONTINENT is not null
group by date
order by 1,2

SELECT  SUM(new_cases) as totalcases,
       SUM(cast(new_deaths as int)) AS totaldeaths,
	   SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as death_percentage
FROM ['Covid_deaths']
WHERE CONTINENT is not null

--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations
FROM ['Covid_deaths'] dea
JOIN ['Covid_vacc$'] vac
     on dea.location =vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--running sum

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations, 
       SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
FROM ['Covid_deaths'] dea
JOIN ['Covid_vacc$'] vac
     on dea.location =vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--use cte
with popvsvacc (continent, location, date, population, new_vacciantions, Rollingpeoplevaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations, 
       SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
FROM ['Covid_deaths'] dea
JOIN ['Covid_vacc$'] vac
     on dea.location =vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
)
SELeCT *, (Rollingpeoplevaccinated/population)*100
from popvsvacc

--Temp table
Create Table percentpeopleVaccinated
(continent nvarchar(255),
Location nvarchar(225),
date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
insert into percentpeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations, 
       SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
FROM ['Covid_deaths'] dea
JOIN ['Covid_vacc$'] vac
     on dea.location =vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null

SELect * FROM percentpeopleVaccinated

--creating view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations, 
       SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
FROM ['Covid_deaths'] dea
JOIN ['Covid_vacc$'] vac
     on dea.location =vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
