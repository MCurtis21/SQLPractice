-----------------------------------------------------------------------------------------------------------------------------------
--Exploring Data

Select *
From SQLPractice.dbo.CovidDeaths
Order by 3, 4

Select *
From SQLPractice.dbo.CovidVaccinations
Order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From SQLPractice.dbo.CovidDeaths
Order by 1, 2

-----------------------------------------------------------------------------------------------------------------------------------
--Let's look at total cases versus total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLPractice.dbo.CovidDeaths
where location like '%states%'
Order by 1, 2

-----------------------------------------------------------------------------------------------------------------------------------
--What percent of population has gotten COVID

Select location, date, total_cases, population, (total_cases/population)*100 as PercentContracted
From SQLPractice.dbo.CovidDeaths
where location like '%states%'
Order by 1, 2

-----------------------------------------------------------------------------------------------------------------------------------
--Which countries have the highest infection rate compared to their population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentInfected
From SQLPractice.dbo.CovidDeaths
--where location like '%states%'
Group by Location, population
Order by PercentInfected desc

-----------------------------------------------------------------------------------------------------------------------------------
--Which countries have the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLPractice.dbo.CovidDeaths
--where location like '%states%'
Group by Location
Order by TotalDeathCount desc

--Some locations are "world" "Europe" "N America" etc. we want to exclude these...

Select *
From SQLPractice.dbo.CovidDeaths
--where location like '%states%'
WHERE continent is not null
Order by 3,4 

--must use 'WHERE continent is not null' to exclude these

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLPractice.dbo.CovidDeaths
--where location like '%states%'
WHERE continent is not null
Group by Location
Order by TotalDeathCount desc

-----------------------------------------------------------------------------------------------------------------------------------
--Which continents have the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLPractice.dbo.CovidDeaths
--where location like '%states%'
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc

-----------------------------------------------------------------------------------------------------------------------------------
--Global Numbers

Select date, sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
From SQLPractice.dbo.CovidDeaths
--where location like '%states%'
WHERE continent is not null
Group By date
Order by 1, 2

-----------------------------------------------------------------------------------------------------------------------------------
--Total Global Death Percentage

Select sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
From SQLPractice.dbo.CovidDeaths
--where location like '%states%'
WHERE continent is not null
--Group By date
Order by 1, 2

-----------------------------------------------------------------------------------------------------------------------------------
--Total population vs vaccinated and creating a column that is showing a rolling count of vaccinations per each country

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VaccinatedRollingCount
From SQLPractice.dbo.CovidDeaths dea
Join SQLPractice.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-----------------------------------------------------------------------------------------------------------------------------------
--Create a vaccinated percentage Using a CTE

With PopvsVac (continent, location, date, population, new_vaccinations, VaccinatedRollingCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VaccinatedRollingCount
From SQLPractice.dbo.CovidDeaths dea
Join SQLPractice.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (VaccinatedRollingCount/population)*100 as PercentPopVaxxed
From PopvsVac

-----------------------------------------------------------------------------------------------------------------------------------
--Let's do the same thing using a Temp Table

Drop Table if exists #PercentPopulationVaccinated
--Must include above if any changes are made
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
VaccinatedRollingCount numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VaccinatedRollingCount
From SQLPractice.dbo.CovidDeaths dea
Join SQLPractice.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

Select *, (VaccinatedRollingCount/population)*100 as PercentPopVaxxed
From #PercentPopulationVaccinated

-----------------------------------------------------------------------------------------------------------------------------------
--Creating views to be used for visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VaccinatedRollingCount
From SQLPractice.dbo.CovidDeaths dea
Join SQLPractice.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select * 
From PercentPopulationVaccinated


