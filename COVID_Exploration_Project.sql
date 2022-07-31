-- Project: COVID-19 Data Exploration  
-- Objective: To find various insights about COVID-19 spread, death, and vaccination status across the globe
-- Data Source: ourworldindata.org
-- No. of Tables: 3 (covid_deaths, covid_vaccination, covid_socio_econ_data)

--EXPLORATION BY LOCATION

-- Exploration Case (1): COVID Cases as Percentage of Total Population of a Country from Feb 24 2020 to July 27 2022
-- Objective: To find an individual's likehood of being infected by COVID
SELECT location, 
		date, 
		population, 
		total_cases, 
		(total_cases/population)*100 as Cases_Percent_of_Population
FROM Portfolio_Project_1..covid_deaths
WHERE continent is NOT NULL
ORDER BY location, 
		 date


-- Exploration Case (2): Total Cases vs Total Deaths of Total Population of a Country from Feb 24 2020 to July 27 2022
-- Objective: To find the an individual's likelihood of dying if caught COVID
SELECT continent, 
		location, 
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio_Project_1..covid_deaths
WHERE continent is NOT NULL
ORDER BY location, 
         date


-- Exploration Case (3): Highest COVID Cases as Percentage of Total Population of a Country from Feb 24 2020 to July 27 2022
-- Objective: To find the Countries with the Highest Infection Rates As Comapred to the Total Population 
SELECT location, 
		population, 
		MAX(total_cases) as Highest_Infection_Count,
		MAX((total_cases/population))*100 as Percent_of_Population_Infected
FROM Portfolio_Project_1..covid_deaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY Percent_of_Population_Infected desc


-- Exploration Case (4): Highest COVID Deaths in a Country from Feb 24 2020 to July 27 2022
-- Objective: To find the Countries with the Highest Deaths 
SELECT location, 
		MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project_1..covid_deaths
WHERE continent is NOT NULL AND total_deaths is NOT NULL
GROUP BY location, population
ORDER BY Total_Death_Count desc


-- Exploration Case (5): MIN(Total Cases) vs Handwashing Facilities from Feb 24 2020 to July 27 2022
-- Objective: To find whether a country Handwashing Facilities has effects on Initial COVID Cases Count
SELECT Death.location,
		Data.handwashing_facilities,
	    MIN(Death.total_cases) as Initial_Cases_Count
FROM Portfolio_Project_1..covid_deaths as Death
JOIN Portfolio_Project_1..covid_socio_econ_data as Data
	ON Death.location = Data.location
WHERE Death.continent IS NOT NULL 
				AND Data.handwashing_facilities IS NOT NULL 
				AND Data.handwashing_facilities > 90
GROUP BY Death.location, 
		 Data.handwashing_facilities
ORDER BY Initial_Cases_Count desc


-- Exploration Case (6): Total Population vs Total Vaccinations from Feb 24 2020 to July 27 2022
-- Objective: To find the how much individuals of the population got vaccinated
SELECT dth.location
	  ,dth.date
	  ,dth.population
	  ,vacci.new_vaccinations
	  ,SUM(CAST(vacci.new_vaccinations as float)) OVER (PARTITION by dth.location ORDER by dth.location,dth.date) as rolling_people_vaccinated
FROM Portfolio_Project_1..covid_deaths as dth
JOIN Portfolio_Project_1..covid_vaccination as vacci
	ON dth.location = vacci.location
	AND dth.date = vacci.date
WHERE dth.continent IS NOT NULL
ORDER by 1,2

-- Calculating Percentage of Population Vaccicated through CTE
With Percentage_of_Population_Vaccicated (Location, Date, Population, NewVaccinations,RollingPeopleVaccinated)
as
(SELECT dth.location
	  ,dth.date
	  ,dth.population
	  ,vacci.new_vaccinations
	  ,SUM(CAST(vacci.new_vaccinations as float)) OVER (PARTITION by dth.location ORDER by dth.location,dth.date) as rolling_people_vaccinated
FROM Portfolio_Project_1..covid_deaths as dth
JOIN Portfolio_Project_1..covid_vaccination as vacci
	ON dth.location = vacci.location
	AND dth.date = vacci.date
WHERE dth.continent IS NOT NULL
)

SELECT *,
	   (RollingPeopleVaccinated/Population)*100 as RollPeopleVaccinatedofPopulation
FROM Percentage_of_Population_Vaccicated


-- Latest Numbers Using Temp Table
DROP TABLE  IF EXISTS #Latest_Data_Vaccination
CREATE TABLE #Latest_Data_Vaccination (
Location nvarchar(50),
Population int,
New_Vaccinations int,
Total_of_Population_Vaccinated float
)

INSERT INTO #Latest_Data_Vaccination
SELECT dth.location
	  ,dth.population
	  ,vacci.new_vaccinations
	  ,SUM(CAST(vacci.new_vaccinations as float)) OVER (PARTITION by dth.location ORDER by dth.location,dth.date) as total_people_vaccinated
FROM Portfolio_Project_1..covid_deaths as dth
JOIN Portfolio_Project_1..covid_vaccination as vacci
	ON dth.location = vacci.location
	AND dth.date = vacci.date
WHERE dth.continent IS NOT NULL


SELECT Location, 
	   Population, 
	   MAX(Total_of_Population_Vaccinated) as Total_People_Vaccinated,
	   (MAX(Total_of_Population_Vaccinated)/Population)*100 as Percentage_of_Population_Vaccinated
FROM #Latest_Data_Vaccination
GROUP BY Location, Population
HAVING (MAX(Total_of_Population_Vaccinated)/Population)*100 <= 100
ORDER BY Percentage_of_Population_Vaccinated desc



--EXPLORATION BY CONTINENT


-- Exploration Case (7): Global Highest COVID Deaths from Feb 24 2020 to July 27 2022
-- Objective: To find the Continents with the Highest Deaths 
SELECT location, 
		MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project_1..covid_deaths
WHERE continent is NULL
GROUP BY location
ORDER BY Total_Death_Count desc



--GLOBAL EXPLORATION

-- Exploration Case (8): Global Total Cases vs Total Deaths from Feb 24 2020 to July 27 2022
-- Objective: To find the Global Deaths as a Percentage of Cases unrolled 
SELECT  date,
		SUM(new_cases) as Global_New_Cases,
		SUM(CAST(new_deaths as int)) as Total_Deaths,
		(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as Deaths_as_Percentage_of_Cases
FROM Portfolio_Project_1..covid_deaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY Deaths_as_Percentage_of_Cases desc


-- Exploration Case (9): Location Total Cases vs Global Total Cases from Feb 24 2020 to July 27 2022
-- Objective: To find how a Country's COVID situation unrolled as comapred to the Global cases
SELECT location,
       date, 
	   total_cases,
	   SUM(total_cases) OVER(PARTITION BY date) as Global_Total_Cases 
FROM Portfolio_Project_1..covid_deaths
WHERE continent is NOT NULL AND total_cases is NOT NULL
ORDER by location, date