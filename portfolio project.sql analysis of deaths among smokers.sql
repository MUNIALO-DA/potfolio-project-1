use portfolio_project;

SHOW COLUMNS FROM portfolio_project.copy_of_coviddeaths;

-- changing the table name from `copy of coviddeaths(1)` TO copy_of_coviddeaths, the innitial cud not be applied in my sql for querries
RENAME TABLE `copy of coviddeaths(1)` TO copy_of_coviddeaths;
RENAME TABLE `copy of covidvaccinations(1)` TO copy_of_covidvaccinations;

-- analysing the emmerging cases of death from covid 19 around the globe in smokers
select new_cases,new_deaths,female_smokers,male_smokers
from copy_of_coviddeaths;
select continent,location,new_cases,new_deaths,female_smokers,male_smokers
from copy_of_coviddeaths
where female_smokers>0 and male_smokers > 0;

-- evaluating their totals
select location,
sum(new_deaths) as total_deaths,
sum(female_smokers) as total_female_smokers,
sum(male_smokers) as total_male_smokers
from copy_of_coviddeaths
where female_smokers > 0 and male_smokers > 0
group by location;

-- wanted to be sure that the figures were true
select * from copy_of_coviddeaths
where female_smokers>0 and male_smokers>0;

select location, female_smokers,male_smokers
from copy_of_coviddeaths;