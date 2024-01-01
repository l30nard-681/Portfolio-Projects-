select *
from PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--- select data that we are going to using 
select Location ,date ,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- Looking at total cases vs total deaths 
select Location ,date ,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

-- Looking at Total Cases Vs Population 
--- shows what percentage of population got covid 
select Location ,date , population,total_cases,(total_cases/population )*100 as PercentPopulationinfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population 

select Location ,population,MAX(total_cases) AS HighestInfectionCount, Max(total_cases/population )*100 as PercentPopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%state%'
Group by population,Location 
order by PercentPopulationinfected desc








-- showing countries with the highest death count per population 
SELECT Location , MAX (cast (Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
-- where location like '%states%'
where continent is not null 
Group by Location 
order by TotalDeathCount desc 




----LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent , MAX (cast (Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
-- where location like '%states%'
where continent is NOT null 
Group by continent
order by TotalDeathCount desc 



 --GLOBAL NUMBERS
 SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_Cases)*100 
 as DeathPercentage
 FROM PortfolioProject..CovidDeaths 
-- where location like '%state%'
 where continent is not null 
 --GROUP BY date 
 order by 1,2 



 ---looking at total population vs vaccination 
 ---use cte
with popvsvac (continent ,location,date ,population ,New_Vaccination ,RollingPeopleVaccinated)
as 
(
 select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by  dea.Location ORDER BY dea.location,
 dea.Date ) as RollingPeopleVaccinated
 ---,(RollingPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100
from popvsvac


--Temp table 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime ,
Population numeric ,
New_vaccinations numeric ,
RollingPeopleVaccinated numeric 
)

insert into #PercentPopulationVaccinated
select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by  dea.Location ORDER BY dea.location,
 dea.Date ) as RollingPeopleVaccinated
 ---,(RollingPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for visualization


create view PercentPopulationVaccinated as 
select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by  dea.Location ORDER BY dea.location,
 dea.Date ) as RollingPeopleVaccinated
 ---,(RollingPeopleVaccinated/population)*100
 from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * from PercentPopulationVaccinated