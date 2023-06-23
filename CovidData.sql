/*
COVID 19 DATE EXPLORATION
USED SKILLS: Joins, CTE's, Temp Tables, Case Statement, Window Function, Aggregate Function, Converting Data types, Creating views
*/
Select *
From PortfolioProject..CovidVaccinations
order by 3,4


Select continent, location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1,2
 

--Checking The Total Cases vs Total Deaths
--Shows the likelyhood of dying from covid when effected in your country
Select location, date, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL) / CAST(total_cases AS DECIMAL))*100
AS DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2 


--Checking The Total Cases vs Population
--Dispalys the number of people that got Covid
Select location, date, total_cases, population,  (CAST(total_cases  AS DECIMAL) / CAST(population AS DECIMAL))*100
AS InfecctedPopulationPercent
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2 


--Cheching The Country with The Highest Infection rate Compared to thier Population 
SELECT
  location,
  population,
  MAX(total_cases) AS MAXtotal_cases,
  MAX(total_cases) / population * 100 AS InfectedPopulationPercent
FROM
  PortfolioProject.dbo.CovidDeaths
  WHERE continent is not NULL
GROUP BY
  location, population
ORDER BY
  InfectedPopulationPercent DESC;


--Countries with The Highest Death Count per population
SELECT
  location,
  population,
  MAX(CAST (total_deaths as int)) AS TotalDeathsCount
FROM
  PortfolioProject.dbo.CovidDeaths
  WHERE continent is not NULL
GROUP BY  
  location, population
ORDER BY
  TotalDeathsCount DESC;


--Countries with the highest death percentage by population
SELECT
  location,
  population,
  MAX(total_deaths) AS MAXtotal_deaths,
  MAX(total_deaths) / population * 100 AS PopulationDeathPercent
FROM
  PortfolioProject.dbo.CovidDeaths
  WHERE continent is not NULL
GROUP BY
  location, population
ORDER BY
  PopulationDeathPercent DESC;



--BREAKING IT BY CONTINENT

--Total Ammount of Covid Cases per Continent
Select 
	location,
	MAX (CAST(total_cases  AS int)) AS TotalCaseCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalCaseCount DESC

Select 
	continent,
	MAX (CAST(total_cases  AS int)) AS TotalCaseCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalCaseCount DESC


--Cheching The Continent with The Highest Infection rate Compared to thier Population 
SELECT
  location,
  MAX (CAST(total_cases  AS int)) AS TotalCaseCount,
  MAX(total_cases) / MAX(population) * 100 AS InfectedPopulationPercent
FROM
  PortfolioProject.dbo.CovidDeaths
  WHERE continent is NULL
GROUP BY
  Location, population
ORDER BY
  InfectedPopulationPercent DESC;


--Countries with The Highest Death Count per population
SELECT
  continent,
  MAX(CAST (total_deaths as int)) AS TotalDeathsCount
FROM
  PortfolioProject.dbo.CovidDeaths
  WHERE continent is not NULL
GROUP BY  
  continent
ORDER BY
  TotalDeathsCount DESC;


--Countries with the highest death percentage by population
SELECT
  location,
  population,
  MAX(total_deaths) AS MAXtotal_deaths,
  MAX(total_deaths) / population * 100 AS PopulationDeathPercent
FROM
  PortfolioProject.dbo.CovidDeaths
  WHERE continent is not NULL
GROUP BY
  location, population
ORDER BY
  PopulationDeathPercent DESC;


--Countinent with The Highest Death Count per population
SELECT 
  location,
  MAX(CAST (total_deaths as int)) AS TotalDeathsCount
FROM
  PortfolioProject.dbo.CovidDeaths
  WHERE continent is null
GROUP BY  
  location
ORDER BY
  TotalDeathsCount DESC;



--GLOBAL NUMBERS

--Total Global New Cases and Death per day
SELECT
  date,
  SUM(new_cases) AS TotalCases,
  SUM(new_deaths) AS TotalDeath
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not Null
GROUP BY date
ORDER BY 1,2

--Total Global Cases, Death and Death Percentage
SELECT
  date,
  SUM(new_cases) AS TotalCases,
  SUM(CAST(new_deaths AS INT)) AS TotalDeath,  
  CASE
    WHEN SUM(new_cases) = 0 THEN NULL
    ELSE (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100
  END AS GlobalDeathPercentage
FROM
  PortfolioProject.dbo.CovidDeaths
WHERE
  continent IS NOT NULL
GROUP BY
  date
ORDER BY
  date, TotalCases;

--Looking at Countries daily amount of New vaccinated people Using CASE
SELECT 
	Death.continent, Death.date, Death.location, Death.population, Vac.new_vaccinations,
CAST(Vac.new_vaccinations as bigint) AS NewVaccinations,
	SUM(CAST(people_vaccinated as bigint)) AS VacinatedPeople
	CASE
		WHEN SUM(CAST(people_vaccinated as int)) = 0 THEN NULL
		ELSE SUM(CAST(people_vaccinated as int))
	END AS TotalVacinated 
FROM
	PortfolioProject.dbo.CovidDeaths AS Death
JOIN 
	PortfolioProject.dbo.CovidVaccinations AS Vac
	ON  
		Death.location = Vac.location
	AND 
		Death.date = Vac.date
GROUP BY 
	Death.continent, Death.date, Death.location, Death.population, 
	CAST(Vac.new_vaccinations as int), CAST(people_vaccinated as int);

--Looking at Countries daily amount of New vaccinated people 
SELECT 
	Death.continent,  Death.location,  Death.date, Death.population, Vac.new_vaccinations
FROM
	PortfolioProject.dbo.CovidDeaths AS Death
JOIN 
	PortfolioProject.dbo.CovidVaccinations AS Vac
	ON  
		Death.location = Vac.location
	AND 
		Death.date = Vac.date
WHERE Death.continent is not NULL
ORDER BY 2,3


--Looking at the Total Population vs Vaccinations per Country or location
-- Shows The Percentage of Population that has Recived at least One vaccine
SELECT 
	Death.continent,  Death.location,  Death.date, Death.population, Vac.new_vaccinations,
	SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Death.location 
	--,(RollingPeopleVaccinated/population)*100
ORDER BY
	Death.location, Death.date) as RollingPeopleVaccinated 
FROM
	PortfolioProject.dbo.CovidDeaths AS Death
JOIN 
	PortfolioProject.dbo.CovidVaccinations AS Vac                 
	ON  
		Death.location = Vac.location
	AND 
		Death.date = Vac.date
WHERE Death.continent is not NULL
ORDER BY 2,3


--USE CTE to calculate the Petition By in the Previous Query
WITH PopvsVac( Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
	Death.continent,  Death.location,  Death.date, Death.population, Vac.new_vaccinations,
	SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Death.location ORDER BY Death.location, Death.date) as RollingPeopleVaccinated 
FROM
	PortfolioProject.dbo.CovidDeaths AS Death
JOIN 
	PortfolioProject.dbo.CovidVaccinations AS Vac                 
	ON  
		Death.location = Vac.location
	AND 
		Death.date = Vac.date
WHERE Death.continent is not NULL
--ORDER BY 2,3
 )
 SELECT *,(RollingPeopleVaccinated/population)*100 FROM PopvsVac


--Using Temp Table to calculate the Petition By in the Previous Query
DROP TABLE if exists #PercentPoulationVaccinated
Create  Table #PercentPoulationVaccinated
(
	continent nvarchar(255),
	loavtion nvarchar(255),
	date datetime,
	Population numeric,
	new_vaccination numeric,
	RollingPeopleVaccinated  numeric
)
insert into #PercentPoulationVaccinated
SELECT 
	Death.continent,  Death.location,  Death.date, Death.population, Vac.new_vaccinations,
	SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Death.location ORDER BY Death.location, Death.date) as RollingPeopleVaccinated 
FROM
	PortfolioProject.dbo.CovidDeaths AS Death
JOIN 
	PortfolioProject.dbo.CovidVaccinations AS Vac                 
	ON  
		Death.location = Vac.location
	AND 
		Death.date = Vac.date
--WHERE Death.continent is not NULL
SELECT *,(RollingPeopleVaccinated/population)*100 FROM #PercentPoulationVaccinated


--Creating Views to Store Data for later Vizualization
create view PercentPoulationVaccinated AS
SELECT 
	Death.continent,  Death.location,  Death.date, Death.population, Vac.new_vaccinations,
	SUM(CONVERT(bigint,Vac.new_vaccinations)) OVER (Partition by Death.location ORDER BY Death.location, Death.date) as RollingPeopleVaccinated 
FROM
	PortfolioProject.dbo.CovidDeaths AS Death
JOIN 
	PortfolioProject.dbo.CovidVaccinations AS Vac                 
	ON  
		Death.location = Vac.location
	AND 
		Death.date = Vac.date
WHERE Death.continent is not NULL
