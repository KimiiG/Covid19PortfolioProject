Select * 
from PortfolioProject..CovidDeaths
order by 3,4

--Select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


Select Location, date, total_cases, total_deaths,(Total_deaths/Total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

Select Location, date, total_cases, total_deaths,(Total_deaths/Total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%states%' and continent is not null
order by 1,2

-- Likelihood of dying if one contracts Covid in Trinidad
Select Location, date, total_cases, total_deaths,(Total_deaths/Total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths

where Location like '%Trinidad%'
and continent is not null
order by 1,2

-- Looking at the total cases vs population
-- Shows what percentage of the population has been infected
Select Location, date, total_cases, population,(Total_cases/population)*100 as PercentageInfected
from PortfolioProject..CovidDeaths

where Location like '%Trinidad%'
order by 1,2

-- Looking at Countries with Highest Infection Rates compared to population
Select Location, MAX(total_cases) as TotalCases, population, Max((Total_cases/population))*100 as PercentageInfected
from PortfolioProject..CovidDeaths
--where Location like '%Trinidad%'
where continent is not null
Group by Location,population
order by 4 DESC

-- Showing the countries with the Highest Death Count per population
Select Location, Max(total_deaths) as TotalDeaths, population, Max((Total_deaths/population))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where Location like '%Trinidad%'
where continent is not null
Group by Location,population
order by 4 DESC

Select Location, Max(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
--where Location like '%Trinidad%'
where continent is not null
Group by Location
order by 2 DESC

-- Break things down by continent

Select Continent, Max(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
--where Location like '%Trinidad%'
where continent is not null
Group by Continent
order by 2 DESC

Select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select Location, Max(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
--where Location like '%Trinidad%'
where continent is null
Group by Location
order by 2 DESC



-- Showing the continent with the Highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
--where Location like '%Trinidad%'
where continent is not null
Group by continent
order by 2 DESC

--Global Numbers
Select Sum(new_cases) as SumOfNewCases, Sum(cast(new_deaths as int)) as SumOfNewDeaths, SUM(cast(New_deaths as int))/SUM(New_cases) * 100 as DeathPercentage -- total_deaths,(Total_deaths/Total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where Location like '%Trinidad%'
where continent is not null

order by 1,2


-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCountOfVaccinations --SUM(CONVERT(int,vac.new_vaccinations))

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVaccination(Continent, Location,Date, Population,NewVaccinations,RollingCountOfVaccinations)
as ( Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCountOfVaccinations --SUM(CONVERT(int,vac.new_vaccinations))
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingCountOfVaccinations/population)*100
from PopvsVaccination

--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCountOfVaccinations --SUM(CONVERT(int,vac.new_vaccinations))
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View percentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCountOfVaccinations --SUM(CONVERT(int,vac.new_vaccinations))
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * from
percentPopulationVaccinated