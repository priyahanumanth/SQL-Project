select * 
From CovidVaccinations$
where continent is not null
order by 3,4


select *
FROM CovidDeaths$
where continent is not null
order by 3,4



select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not null
order by 1,2


select location, date, total_cases, total_deaths,( total_deaths/total_cases)*100 as Death_Percentage
FROM CovidDeaths$
where location like '%india%'
order by 1,2



select location, date, total_cases, population,(total_deaths/population)*100 as Mortality_Rate
FROM CovidDeaths$
where continent is not null
order by 1,2



-- SHOWING HIGH_INFECTION RATE IN COUNTRIES

select location, population ,max(total_cases) as High_infectionrate ,
(max(total_cases)/population)*100 as percentpopulation_infected
FROM CovidDeaths$ group by location,population 
order by location  asc;



--SHOWING HIGH_DEATHCOUNT RATE IN COUNTRIES

select location,population ,max(total_deaths) as high_death_rate ,
(max(total_deaths)/population )*100 as max_death_rate
FROM  CovidDeaths$  
where continent is not null
group by location,population
order by max_death_rate desc


--SHOWING TOTAL DEATH COUNT

select continent,max(cast(total_deaths as int)) as total_death_count
FROM CovidDeaths$
where continent is not null
group by continent
order by total_death_count desc


--GLOBAL NUMBERS

select  date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
FROM CovidDeaths$
where continent is not null
group by date
order by 1,2


--JOIN TWO TABLES

select * from CovidDeaths$ dea
join CovidVaccinations$ vac
    on dea.date =vac.date
    and dea.location= vac.location

--Looking at total populations and vaccinations

--USE CTE

WITH popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--(Rollingpeople_vaccinated/population)*100
FROM CovidDeaths$ dea
join CovidVaccinations$ vac
       on dea.date = vac.date
       and dea.location = vac.location
where dea.continent is not null
--order by 2,3
)

select * , (Rollingpeoplevaccinated/POPULATION)*100
FROM popvsvac

--TEMP TABLE
DROP table if exists #percentpopulationvaccinated
CREATE table #percentpopulationvaccinated
(
continent varchar(200),
location varchar(200),
date datetime,
population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric)

Insert into #percentpopulationvaccinated

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--(Rollingpeople_vaccinated/population)*100
FROM CovidDeaths$ dea
join CovidVaccinations$ vac
       on dea.date = vac.date
       and dea.location = vac.location 
-- where dea.continent is not null
--order by 2,3

select *, (Rollingpeoplevaccinated/Population)*100
FROM #percentpopulationvaccinated

-- CREATING VIEW TO STORE FOR DATA VISUALIZATION
 
 create view percentpopulationvaccinated
 as
 select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--(Rollingpeople_vaccinated/population)*100
FROM CovidDeaths$ dea
join CovidVaccinations$ vac
   on dea.date = vac.date
   and dea.location = vac.location 
where dea.continent is not null
order by 2,3

select * FROM percentpopulationvaccinated;
