#test data was loaded and formated properly

#Select * 
#From portfolioproject.coviddeaths
#order by 3,4;

#Select * 
#From portfolioproject.covidvaccinations
#order by 3,4;

#select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioproject.coviddeaths
order by 1,2 ;

#looking at total cases vs total deaths aka % of positive cases who die
#using wildcard states to find location name for united states
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From portfolioproject.coviddeaths
Where location like '%states%'
order by Location, date ;

#looking at total cases vs population

Select Location, date, Population, total_cases, (total_cases/Population)*100 as population_infected
From portfolioproject.coviddeaths
Where location like 'United States'
order by 1,2 ;

#Looking for country with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as highest_infection_count, MAX((total_cases/Population))*100 as population_infected
From portfolioproject.coviddeaths
Group by Location, Population
order by population_infected desc ;

#looking for countries with highest deathcount per population

Select Location, MAX(total_deaths) as total_death_count
From portfolioproject.coviddeaths
#null continent attribute is causing an error
Where continent is not null
Group by Location
order by total_death_count desc ;

#looking total death count by continent

Select continent, MAX(total_deaths) as total_death_count
From portfolioproject.coviddeaths
Where continent is not null
Group by continent
order by total_death_count desc ; 


#looking for global numbers
Select date, SUM(new_cases), SUM(new_deaths) as global_total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as global_death_percentage
From portfolioproject.coviddeaths
where continent is not null
group by date
order by 1,2 ;

#look at covid vacc
Select *
From portfolioproject.covidvaccinations ;

#USE CTE

#join tables
#look at total population vs vaccination
#with rolling sum by location w partitions

With PopVsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From portfolioproject.coviddeaths dea
Join portfolioproject.covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
)
Select *, (rolling_people_vaccinated/population)*100 as percent_vaccinated
From PopVsVac;
