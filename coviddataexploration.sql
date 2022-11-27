--select *
--from project.dbo.covideaths
--where location='India'
--order by 3,4


--total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as percentage_deaths
from project..covideaths
where location='India'
order by 1,2

 --total deaths vs total population
 select location,date,total_cases,population,(total_deaths/population)*100 as percentage_deaths
from project..covideaths
where location='India'
order by 1,2

--countries with highest infection rate compared to population
select location,population , max(total_cases) as cases, max((total_cases/population)*100) as percentageinfected 
from project..covideaths
group by location,population 
order by percentageinfected desc

--countries with highest death count per population
select Location, continent , MAX(cast(Total_deaths as int)) as totaldeathcount
from project..covideaths
where continent is not null
group by Location , continent
order by totaldeathcount desc

--continents with highest death count 
select continent,sum(totaldeathcount) as deaths from (
select Location, continent , MAX(cast(Total_deaths as int)) as totaldeathcount
from project..covideaths
where continent is not null 
group by Location , continent) new
group by continent
order by deaths desc


select distinct continent,sum(cast(new_deaths as int)) over (partition by continent) as deaths 
from project..covideaths
where continent is not null
order by deaths desc






--continets with highest death count per percenatge death per population
select continent,sum(totaldeathcount) as deaths,sum(population) as totalpopulation , (sum(totaldeathcount)/sum(population))*100 as percentage
from (
select Location, continent ,population, MAX(cast(Total_deaths as int)) as totaldeathcount
from project..covideaths 
where continent is not null 
group by Location , continent,population) new
group by continent

--global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From project..Covideaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

From Project..Covideaths dea
Join Project..Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- percentage people vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date)/population)*100
From Project..Covideaths dea
Join Project..Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


with vax(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date)/population)*100
From Project..Covideaths dea
Join Project..Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *,(RollingPeopleVaccinated/Population)*100 as percentagevax from vax


--temp table
create table #centpeoplevaccinated(
 continent nvarchar(40), location nvarchar(40) , date datetime , population numeric , new_vaccinations numeric , rollingpeoplevaccinated bigint)

 insert into #centpeoplevaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date)/population)*100
From Project..Covideaths dea
Join Project..Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *,(RollingPeopleVaccinated/Population)*100 as centpeopulationvaccinated from #centpeoplevaccinated

--creating view
create view percentagevaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date)/population)*100  as percentagepeoplevaccinated
From Project..Covideaths dea
Join Project..Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from percentagepeoplevaccinated