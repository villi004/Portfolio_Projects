--select data that we are going to be using

Select Location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_Deaths
order by 1,2


--total cases vs total deaths, 


Select Location,date, total_cases, total_deaths, (cast(total_deaths as bigint))/(cast(total_cases as bigint))*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
Where location like '%states%'
order by 1,2




--Total cases vs population, what percentage of population got covid

Select Location,date, population, total_cases, (cast(total_cases as bigint))/population*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
order by 1,2


--Countries with Highest Infection rate compared to population


Select Location, population, Max(cast(total_cases as bigint)) as HighestInfectionCount,MAX((cast(total_cases as bigint))/population) *100 as 
 PercentPopulationInfected
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc


--Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
where continent is not null
Group by Location, population
order by TotalDeathCount desc


--Highest death count by company

Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

Select continent, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Continents with the highest death count per population

Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

--Global Numbers 


Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SuM(cast(new_deaths as bigint))/
nullif(SUM(new_cases), 0) *100 as DeathPercentage
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2


--total world 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SuM(cast(new_deaths as bigint))/
nullif(SUM(new_cases), 0) *100 as DeathPercentage
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2



--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
Order by 2,3 



--Use CTE

With PopVSVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null 
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopVSVac


With PopVSVac (Continent, Location, Population,New_Vaccinations, RollingPeopleVaccinated)
as
( 
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null 
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopVSVac


--Temp table
DROP Table if exists #PercentPopulationVaccinated
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
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null 

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null 
--order by 2,3



Select*
From PercentPopulationVaccinated

Create view TotalDeathCount as
Select continent, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
where continent is not null
Group by continent
--order by TotalDeathCount desc