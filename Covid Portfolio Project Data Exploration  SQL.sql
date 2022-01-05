Select *
From portfolioproject..CovidDeaths
where continent is not null
order by 3,4 

--Select *
--from portfolioproject..CovidVaccinations
--order by 3,4

--Selection of Data

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioproject..CovidDeaths
where continent is not null
order by 1,2 

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2 

--looking at Total cases vs Population
--shows what percentage of population got covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, max( total_cases) as HighestInfectionCount, Population, Max(total_cases/population)*100 as PercentPopulationInfected
From portfolioproject..CovidDeaths
--where location like '%states%'
--where continent is not null
Group by Location,Population
order by  PercentPopulationInfected desc

--Showing Countries with Highest Death Count per population

Select Location, Max(cast( total_deaths as int )) as TotalDeathCount
From portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by  TotalDeathCount desc



--LET's Break Things Down By Continent

--Showing the  continents with the highest death count per population

Select continent, Max(cast( total_deaths as int )) as TotalDeathCount
From portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by  TotalDeathCount desc



--Global Numbers


Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2 


----Looking at  total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
       On dea.location = vac.location
       and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac(Continent, Location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations )) OVER(Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE


Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations )) OVER(PARTITION by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
         On dea.location = vac.location
         and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations )) OVER(PARTITION by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
        On dea.location = vac.location
        and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated