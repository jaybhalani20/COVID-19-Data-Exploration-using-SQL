Select *
from DAportfolio..CovidDeaths
order by 3,4

--Select *
--from DAportfolio..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from DAportfolio..CovidDeaths
order by  1,2

--Total cases vs Total deaths
Select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as Death_Percentage
from DAportfolio..CovidDeaths
where location like '%india%'
order by  1,2

--total cases vs population
--how many people got covid
Select location, date, total_cases, population, (total_cases/population)*100 as PeopleCovidPercent
from DAportfolio..CovidDeaths
where location like '%india%'
order by  1,2

--looking for the highest infection rate compared to population
Select location,population, Date, MAX(total_cases),MAX((total_cases/population)*100) as PeopleCovidPercent
from DAportfolio..CovidDeaths
Group by location, population, Date
order by PeopleCovidPercent desc

--countries with highest death counts
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from DAportfolio..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--based on continents
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from DAportfolio..CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathCount desc

--Death % at global level
Select SUM(new_cases) as Total_cases,Sum(cast(new_deaths as int)) as Total_deaths,Sum(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from DAportfolio..CovidDeaths 
Where continent is not null
--Group by date
order by 1,2 

--total population vs vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
from DAportfolio..CovidDeaths as dea
join DAportfolio..CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--more optimized (cummulative frequency)
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cummulativevaccination
from DAportfolio..CovidDeaths as dea
join DAportfolio..CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--A CTE (Common Table Expression) in SQL is a temporary result set.
with popvsvac (continent,location,date,population,new_vaccinations,cummulativevaccination)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cummulativevaccination
from DAportfolio..CovidDeaths as dea
join DAportfolio..CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
Select *, (cummulativevaccination/population)*100 as cummulative_percentage
from popvsvac

--temp table 

create table temp_table
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cummulativevaccination numeric)
insert into temp_table
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cummulativevaccination
from DAportfolio..CovidDeaths as dea
join DAportfolio..CovidVaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null

Select *, (cummulativevaccination/population)*100 as cummulative_percentage
from temp_table

--creating views for future visualization
CREATE VIEW view_covid_data AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    -- Cumulative sum of vaccinations over time for each location
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cummulativevaccination,
    -- Calculate the cumulative percentage of vaccinated people
    (SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS cummulative_percentage
FROM 
    DAportfolio..CovidDeaths AS dea
JOIN 
    DAportfolio..CovidVaccinations AS vac
ON 
    dea.location = vac.location
AND 
    dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


Select SUM(new_cases)as total cases,

--for tableau
Select location,Sum(cast(new_deaths as int)) as Total_deaths
from DAportfolio..CovidDeaths 
Where continent is null
Group by location
order by total_deaths desc

