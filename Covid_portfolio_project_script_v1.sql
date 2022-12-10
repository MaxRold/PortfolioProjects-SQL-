 select * from "CovidInfo"."CovidDeaths"
order by 3,4


-- Select data that we will use

select location, date, total_cases, new_cases, total_deaths, population 
from "CovidInfo"."CovidDeaths"
where continent is not null
order by 1,2


-- Looking at Total cases vs Total Deaths in Russia

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_perc
from "CovidInfo"."CovidDeaths"
where continent is not null and location = 'Russia'
order by 1,2

-- Looking at Total cases vs Population
-- What percentage of population got Covid

select location, date, population, total_cases, (total_cases /population)*100 as death_perc
from "CovidInfo"."CovidDeaths"
where continent is not null
order by 1,2

-- Looking at Country with Highest infection rate compared to Population

select location, population, max(total_cases) as highest_infection_count, max((total_cases /population))*100 as perc_of_pop_infected
from "CovidInfo"."CovidDeaths"
where continent is not null and not location = 'International' and not location = 'World'
group by location, population
order by perc_of_pop_infected 

--Sowing Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as total_death_count
from "CovidInfo"."CovidDeaths"
where continent is not null
and not location = 'South America'
and not location = 'Lower middle income'
and not location = 'Asia'
and not location = 'Africa'
and not location = 'North America'
and not location = 'Europe'
and not location = 'Upper middle income'
and not location = 'High income'
and not location = 'Low income'
and not location = 'World'
and not location = 'Oceania'
and not location = 'European Union'
and not location = 'International'
group by location, population
order by total_death_count desc

select location, max(total_deaths) as total_death_count
from "CovidInfo"."CovidDeaths"
where continent = ''
and not location = 'High income'
and not location = 'Low income'
and not location = 'Upper middle income'
and not location = 'Lower middle income'
and not location = 'European Union'
and not location = 'International'
group by location 
order by total_death_count desc



-- Global numbers

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths , sum(new_deaths)/sum(new_cases)*100 as death_perc
from "CovidInfo"."CovidDeaths"
where continent is not null and new_cases != 0
and not location = 'South America'
and not location = 'Lower middle income'
and not location = 'Asia'
and not location = 'Africa'
and not location = 'North America'
and not location = 'Europe'
and not location = 'Upper middle income'
and not location = 'High income'
and not location = 'Low income'
and not location = 'World'
and not location = 'Oceania'
and not location = 'European Union'
and not location = 'International'
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths , sum(new_deaths)/sum(new_cases)*100 as death_perc
from "CovidInfo"."CovidDeaths"
where continent is not null
and not location = 'South America'
and not location = 'Lower middle income'
and not location = 'Asia'
and not location = 'Africa'
and not location = 'North America'
and not location = 'Europe'
and not location = 'Upper middle income'
and not location = 'High income'
and not location = 'Low income'
and not location = 'World'
and not location = 'Oceania'
and not location = 'European Union'
and not location = 'International'
order by 1,2


-- Total population vs vaccination

update "CovidInfo"."CovidVaccinations"
set new_vaccinations = 0
where new_vaccinations = ''
select new_vaccinations from "CovidInfo"."CovidVaccinations"

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int))
over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from "CovidInfo"."CovidDeaths" cd
join "CovidInfo"."CovidVaccinations" cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
and not cd.location = 'South America'
and not cd.location = 'Lower middle income'
and not cd.location = 'Asia'
and not cd.location = 'Africa'
and not cd.location = 'North America'
and not cd.location = 'Europe'
and not cd.location = 'Upper middle income'
and not cd.location = 'High income'
and not cd.location = 'Low income'
and not cd.location = 'World'
and not cd.location = 'Oceania'
and not cd.location = 'European Union'
and not cd.location = 'International'
order by 2,3

-- Use CTE(A common table expression) is a temporary named result set created from a simple SELECT statement that can be used in a subsequent SELECT statement

with PopVsVac (Continent, Location, Date, Population, New_vaccinations, Rolling_people_vaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from "CovidInfo"."CovidDeaths" cd
join "CovidInfo"."CovidVaccinations" cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
and not cd.location = 'South America'
and not cd.location = 'Lower middle income'
and not cd.location = 'Asia'
and not cd.location = 'Africa'
and not cd.location = 'North America'
and not cd.location = 'Europe'
and not cd.location = 'Upper middle income'
and not cd.location = 'High income'
and not cd.location = 'Low income'
and not cd.location = 'World'
and not cd.location = 'Oceania'
and not cd.location = 'European Union'
and not cd.location = 'International'
order by 2,3
)
select *, (Rolling_people_vaccinated/Population)*100
from PopVsVac
where Rolling_people_vaccinated !=0


-- Create a temp table 

drop table if exists "CovidInfo".PercentPopulationVaccinated

create table "CovidInfo".PercentPopulationVaccinated
(Continent varchar(255), 
location varchar(255), 
Date date, 
Population numeric, 
New_vaccinations numeric, 
Rolling_people_vaccinated numeric
)

insert into "CovidInfo".PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from "CovidInfo"."CovidDeaths" cd
join "CovidInfo"."CovidVaccinations" cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
and not cd.location = 'South America'
and not cd.location = 'Lower middle income'
and not cd.location = 'Asia'
and not cd.location = 'Africa'
and not cd.location = 'North America'
and not cd.location = 'Europe'
and not cd.location = 'Upper middle income'
and not cd.location = 'High income'
and not cd.location = 'Low income'
and not cd.location = 'World'
and not cd.location = 'Oceania'
and not cd.location = 'European Union'
and not cd.location = 'International'
order by 2,3

select *, (Rolling_people_vaccinated/Population)*100
from "CovidInfo".PercentPopulationVaccinated
where Rolling_people_vaccinated !=0


-- Creating table for viewing later

create view "CovidInfo".PercPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from "CovidInfo"."CovidDeaths" cd
join "CovidInfo"."CovidVaccinations" cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
and not cd.location = 'South America'
and not cd.location = 'Lower middle income'
and not cd.location = 'Asia'
and not cd.location = 'Africa'
and not cd.location = 'North America'
and not cd.location = 'Europe'
and not cd.location = 'Upper middle income'
and not cd.location = 'High income'
and not cd.location = 'Low income'
and not cd.location = 'World'
and not cd.location = 'Oceania'
and not cd.location = 'European Union'
and not cd.location = 'International'
order by 2,3

select * from "CovidInfo".percpopulationvaccinated