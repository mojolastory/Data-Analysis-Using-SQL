/****** Script for SelectTopNRows command from SSMS  ******/
SELECT location, date,total_cases,new_cases, total_deaths, population
  FROM [covid deaths]
  ORDER BY 1,2

--Total cases vs Total Deaths
SELECT location, date,total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS Death_percentage
  FROM [covid deaths]
  WHERE location like 'Africa%'
  ORDER BY 1,2

  --Total Cases vs Population
  SELECT location, date,total_cases, Population, (total_cases/population)*100 AS Population_percentage
  FROM [covid deaths]
  --WHERE location like 'Africa%'
  ORDER BY 1,2

  --Countries with highest infection rate compared to population
  SELECT location, population, max(total_cases)as highest_infection_count, max(total_cases/population)*100 
  AS percent_population_infected
  FROM [covid deaths]
  Group by location,population
  ORDER BY percent_population_infected desc

  -- Top 10 countries with highest death count per poupulation
SELECT Top 10
location, max(cast(total_deaths as int))as Death_count
  FROM [covid deaths]
  where continent is not null
  Group by location
  ORDER BY Death_Count DESC

 --Continent with highest death count per poupulation
  SELECT location, max(cast(total_deaths as int))as Death_count
  FROM [covid deaths]
  where continent is null
  Group by location
  ORDER BY Death_Count DESC

  --Global cases
  SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
  sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percent
  FROM [covid deaths]
  WHERE continent IS NOT NULL
  GROUP BY date
  ORDER BY 1,2


--Rolling Total population vs vaccinations
 SELECT dea.continent, dea.location, dea.date, dea.population,convert(int,vac.new_vaccinations), 
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.date) as Rolling_people_vaccinated
 FROM [covid deaths] dea 
 JOIN [covid vaccines] vac
	ON dea.location=vac.location
	AND dea.date=vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3 

 --With CTE
 WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, Rolling_people_vaccinated)
 AS
 (
  SELECT dea.continent, dea.location, dea.date, dea.population,convert(int,vac.new_vaccinations), 
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.date) as Rolling_people_vaccinated
 FROM [covid deaths] dea 
 JOIN [covid vaccines] vac
	ON dea.location=vac.location
	AND dea.date=vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3 
 )
 Select *, (Rolling_people_vaccinated/Population)*100
 From PopvsVac

 --Temp Table
 DROP TABLE if exists #percent_population_vaccinated
 CREATE TABLE #percent_population_vaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 Rolling_people_vaccinated numeric
 )

 Insert into #percent_population_vaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population,convert(int,vac.new_vaccinations), 
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
 dea.date) as Rolling_people_vaccinated
 FROM [covid deaths] dea 
 JOIN [covid vaccines] vac
	ON dea.location=vac.location
	AND dea.date=vac.date
 --WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3 
 
 Select*, (Rolling_people_vaccinated/Population)*100 
 From #percent_population_vaccinated
 
 --Creating views to store data for visualisation
 Create view CountriesWithHighestDeathCounts as
 SELECT location, max(cast(total_deaths as int))as Death_count
  FROM [covid deaths]
  where continent is not null
  Group by location
  --ORDER BY Death_Count DESC

  Select * from [covid deaths]

  --Hospital patients vs ICU patients
  Create view patients as
  SELECT location, date, hosp_patients, icu_patients--,(cast(hosp_patients as int)/icu_patients)*100 AS hosp_percentage
  FROM [covid deaths]
  ORDER BY 1,2