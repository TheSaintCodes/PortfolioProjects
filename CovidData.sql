--SELECT 
--	Death.continent, Death.date, Death.location, Death.population, Vac.new_vaccinations,
--CAST(Vac.new_vaccinations as bigint) AS NewVaccinations,
--	SUM(CAST(people_vaccinated as bigint)) AS VacinatedPeople
--	CASE
--		WHEN SUM(CAST(people_vaccinated as int)) = 0 THEN NULL
--		ELSE SUM(CAST(people_vaccinated as int))
--	END AS TotalVacinated 
--FROM
--	PortfolioProject.dbo.CovidDeaths AS Death
--JOIN 
--	PortfolioProject.dbo.CovidVaccinations AS Vac
--	ON  
--		Death.location = Vac.location
--	AND 
--		Death.date = Vac.date
--GROUP BY Death.continent, Death.date, Death.location, Death.population, CAST(Vac.new_vaccinations as int), CAST(people_vaccinated as int);


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

--Looking at the Total Population vs Vaccinations
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
ORDER BY 2,3
 


--USE CTE
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



--Using Temp Table
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