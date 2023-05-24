select *
from CovidDeaths$
where continent is not null
order by 3,4

--select *
--from CovidVaccinations$
--order by 3,4

-- Selectam datele pe care le vom folosi

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1, 2


-- Ne uitam la total_cases vs total_deaths
-- Arata sansele de moarte daca ai covid in tara ta
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%romania%'
order by 1, 2

-- Ne uitam la total_cases vs population
-- Vedem procentul populatiei care a luat covid
select location, date, population,total_cases ,(total_cases/population)*100 as InfectedPercentage
from CovidDeaths$
--where location like '%romania%'
order by 1, 2

--Ne uitam la tarile cu cea mai mare rata de infectare raportata la populatie

select location, population,max(total_cases) as HighestInfectionCount ,max((total_cases/population))*100 as InfectedPercentage
from CovidDeaths$
--where location like '%romania%'
group by location, population
order by InfectedPercentage desc

--Ne uitam la tarile cu cea mai mare rata de mortalitate

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%romania%'
where continent is not null
group by location, population
order by TotalDeathCount desc

--Per continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%romania%'
where continent is not null
group by continent
order by TotalDeathCount desc

--select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--from CovidDeaths$
----where location like '%romania%'
--where continent is null
--group by location
--order by TotalDeathCount desc


--Arata continentele cu cele mai multe decese pe populatie

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%romania%'
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
--group by date
order by 1,2


--populatia totala vs vaccinare

select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- folosim CTE

with PopvsVac(continent, location, date, population, new_vaccinatons, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creem un view pentru a stoca datele

create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated