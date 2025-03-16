select *
from
PortfolioProject.dbo.PortfolioProject;

select *
from
PortfolioProject.dbo.coviddeaths;

EXEC sp_rename 'dbo.PortfoliProject', 'coviddeaths';

SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'NewTableName';


----select *
----from
----PortfolioProject.dbo.covidvaccinations;



select location, date,total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1,2;

--total case vs total deaths
-- the rate of deaths from covid in a particular country

select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpecerntage
from PortfolioProject..coviddeaths
where location like '%states%'
order by 1,2;


select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpecerntage
from PortfolioProject..coviddeaths
where location like 'kenya' 
order by 1,2;

--total cases vs poulation
percentage of population infected

select location, date,total_cases, population, (total_cases/population)*100 as deathpecerntage
from PortfolioProject..coviddeaths
where location like 'kenya' 
order by 1,2;
 
-- countries with highest infection rates in Asia


select continent, location, population,max(total_cases) as highest_count, max((total_cases/population))*100 as percentagepopulationinfected
from PortfolioProject..coviddeaths
where continent like '%ASIA%'
group by continent,location, population
order by  percentagepopulationinfected;




select continent, location, population,max(total_cases) as highest_count, max((total_cases/population))*100 as percentagepopulationinfected
from PortfolioProject..coviddeaths
where continent like '%Africa%'
group by continent,location, population
order by  percentagepopulationinfected;

--showing with the highest death count in Africa, asia, states

select continent, location,max(total_deaths) as totaldeath_count
from PortfolioProject..coviddeaths
where continent like '%Africa%'
group by continent,location
order by totaldeath_count desc;



select continent, location,max(total_deaths) as totaldeath_count
from PortfolioProject..coviddeaths
where continent like '%America%'
group by continent,location
order by totaldeath_count desc;


-- further analyses per continent

select location,max(cast(total_deaths as int)) as totaldeath_count 
from PortfolioProject..coviddeaths
--where location like '%america%'
where continent is not null
group by location
order by totaldeath_count desc;

--continents with the highest death count

select continent, location,max(total_deaths) as totaldeath_count
from PortfolioProject..coviddeaths
where continent like '%Asia%'
group by continent,location
order by totaldeath_count desc;


--global numbers

select date, Sum(new_cases) as globalnumbersperday
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2;



select date, Sum(new_cases) as globalnumbersperday, sum(cast(new_deaths as int)) as globaldeathsperday
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2;


select date, Sum(new_cases) as globalnumbersperday, sum(cast(new_deaths as int)) as globaldeathsperday, sum(cast(new_deaths as int))/ Sum(new_cases)*100 as deathrateglobaly
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2;



select Sum(new_cases) as globalnumbersperday, sum(cast(new_deaths as int)) as globaldeathsperday, sum(cast(new_deaths as int))/ Sum(new_cases)*100 as deathrateglobaly
from PortfolioProject..coviddeaths
where continent is not null
--group by date
order by 1,2;



--joins, unions, partition by
--assesing the total population versus vaccinations


select *
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
     on dea.location= vac.location
	 and dea.date=vac.date;

	 

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
     on dea.location= vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 order by 2,3 desc;

	  --getting running totals for deaths for different locations
	  
select continent,location,date,population, total_deaths,sum(Cast(total_deaths as int))
     over (partition by location order by location, date) as rollingdeaths
from PortfolioProject..coviddeaths
	 where continent is not null
	 order by 2,3;

	 --geting the running totals for people vaccitated per location

	 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
     over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
     on dea.location= vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 order by 2,3 desc;

	

	  
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
     over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
	--  (rollingpeoplevaccinated/population)*100  (source of error)
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
     on dea.location= vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 order by 2,3 desc;
	
	--Msg 207, Level 16, State 1, Line 177
--Invalid column name 'rollingpeoplevaccinated'. we cant use arow that we've just created to perform operations immedietltly  so we are prompted to use CTE to help usz do that.

	 --use CTE

WITH popsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(CAST(COALESCE(vac.new_vaccinations, 0) AS BIGINT)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
    FROM PortfolioProject..coviddeaths dea
    JOIN PortfolioProject..covidvaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT 
    *, 
    LEAST((CAST(rollingpeoplevaccinated AS FLOAT) / population) * 100, 100) 
    AS vaccination_percentage
FROM popsvac;


--create views for visualization
CREATE VIEW mortalityratesinkenya AS 
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths * 100.0 / NULLIF(total_cases, 0)) AS deathpercentage
FROM PortfolioProject..coviddeaths
WHERE location = 'Kenya'  -- Ensuring proper case
--ORDER BY location, date;

IF OBJECT_ID('dbo.mortalityratesinkenya', 'V') IS NOT NULL
    DROP VIEW dbo.mortalityratesinkenya;
GO

CREATE VIEW dbo.mortalityratesinkenya AS 
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths * 100.0 / NULLIF(total_cases, 0)) AS deathpercentage
FROM PortfolioProject..coviddeaths
WHERE location = 'Kenya';  -- Ensuring proper case

IF OBJECT_ID('dbo.vaccination_percentage', 'V') IS NOT NULL
    DROP VIEW dbo.vaccination_percentage;
GO

CREATE VIEW dbo.vaccination_percentage AS
WITH popsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(CAST(COALESCE(vac.new_vaccinations, 0) AS BIGINT)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
    FROM PortfolioProject..coviddeaths dea
    JOIN PortfolioProject..covidvaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT 
    *, 
    CASE 
        WHEN (CAST(rollingpeoplevaccinated AS FLOAT) / population) * 100 > 100 
        THEN 100 
        ELSE (CAST(rollingpeoplevaccinated AS FLOAT) / population) * 100 
    END AS vaccination_percentage
FROM popsvac;

