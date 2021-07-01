SELECT *
FROM PortofolioProject.dbo.CovidDeaths
ORDER by 3,4

--SELECT *
--FROM PortofolioProject.dbo.CovidVaccinations
--ORDER by 3,4

--SELECT data yang akan di gunakan

--pilih semua entry pada kolom Location, date, total_cases, new_cases, total_deaths, dan population
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject.dbo.CovidDeaths
ORDER by 1,2

--Melihat Total Case dibandingkan dengan Total Deaths di indonesia, dan kemungkinan kotor 
--kematian jika tertular Covid-19 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject.dbo.CovidDeaths
WHERE location like '%indo%'
ORDER by 1,2

--Melihat case total dgn population
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM PortofolioProject.dbo.CovidDeaths
WHERE location like '%indo%'
ORDER by 1,2
--Kecil jika dibandingkan dengan Amerika, tapi tetap tinggi dan ada kemungkinan memang kurang inisiatif 
--oleh masyarakat untuk mengambil tes covid mandiri


--Melihat negara dengan case tertinggi, plus persentasi
SELECT Location, Population, MAX(total_cases) AS HIghestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortofolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Melihat negara dengan kematian tertinggi, plus persentasi
SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Kematian tertinggi berdasarkan benua
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioProject.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Infeksi dan kemation Covid-19 di indonesia
SELECT location, MAX(cast(total_cases AS INT)) AS TotalCases, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioProject.dbo.CovidDeaths
WHERE location like '%indo%'
GROUP BY location

--total case dan kematian, plus persentasi
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortofolioProject.dbo.CovidDeaths
ORDER BY 1,2

--melihat populasi total dengan vaksinasi dan rolling count tervaksinasi
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortofolioProject.dbo.CovidDeaths dea
JOIN PortofolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--melihat rolling count yang sudah tervaksinasi di indonesia
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortofolioProject.dbo.CovidDeaths dea
JOIN PortofolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location like '%indo%'
ORDER BY 2,3

--pengetesan CTE untuk persentase rolling yang sudah tervaksinasi dibandingkan populasi
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortofolioProject.dbo.CovidDeaths dea
JOIN PortofolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location like '%indo%'
)
SELECT *, (RollingVaccinated/population)*100
FROM PopvsVac

--table TEMP
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortofolioProject.dbo.CovidDeaths dea
JOIN PortofolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location like '%indo%'

SELECT *, (RollingVaccinated/population)*100
FROM #PercentPopulationVaccinated

--membuat VIEW untuk visualisasi nanti
CREATE VIEW PercentVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM PortofolioProject.dbo.CovidDeaths dea
JOIN PortofolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location like '%indo%'
--dan di tes
SELECT *
FROM PercentVaccinated