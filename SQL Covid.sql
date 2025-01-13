-- Covid 19 Data Exploration with Karan Shah
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types
-------------------------------------------------------------------------------------------------------------------------------------
-- Select Data that we are going to be using

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    CovidDeaths
ORDER BY location , date;

-------------------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Total Deaths Globally

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
ORDER BY location , date;

-------------------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Total Deaths in United States

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    CovidDeaths
WHERE
    location = 'United States'
ORDER BY date;

-------------------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Population
-- Shows what percentage of US population got Covid

SELECT 
    location,
    date,
    total_cases,
    population,
    (total_cases / population) * 100 AS CovidPercentage
FROM
    CovidDeaths
WHERE
    location = 'United States'
ORDER BY date;

-------------------------------------------------------------------------------------------------------------------------------------
-- Looking at Countries with Highest Infection Rate compared to Population

SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    CovidDeaths
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC;

-------------------------------------------------------------------------------------------------------------------------------------
-- Showing Countries with Highest Death Count

Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc;

-------------------------------------------------------------------------------------------------------------------------------------
-- Showing Death Count by Continent

Select continent, sum(TotalDeathCount) as TotalDeathCount
From (
Select continent, location, MAX(cast(total_deaths as float)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent, location 
) as deathcountbycountry
Group by continent
Order by TotalDeathCount desc;

-------------------------------------------------------------------------------------------------------------------------------------
-- Global Numbers
-- Total Cases, Death, and Death Percentage by Date

SELECT 
    date, 
    SUM(new_cases) AS TotalCases, 
    SUM(CAST(new_deaths AS FLOAT)) AS TotalDeaths, 
    (SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    date;

-------------------------------------------------------------------------------------------------------------------------------------
-- Total Cases, Deaths and Death Percentage Overall

SELECT 
    SUM(new_cases) AS TotalCases, 
    SUM(CAST(new_deaths AS FLOAT)) AS TotalDeaths, 
    (SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL;

-------------------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations_1,
    SUM(CAST(vac.new_vaccinations_1 AS FLOAT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    CovidDeaths AS dea
JOIN 
    CovidVaccinations AS vac
    ON dea.location = vac.location_1
    AND dea.date = vac.date_1
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    dea.location, 
    dea.date;

-------------------------------------------------------------------------------------------------------------------------------------
-- Using CTE to Calculate Total Vaccination Percentage By Date

WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations_1,
        SUM(CAST(vac.new_vaccinations_1 AS FLOAT)) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM 
        CovidDeaths AS dea
    JOIN 
        CovidVaccinations AS vac
        ON dea.location = vac.location_1
        AND dea.date = vac.date_1
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM 
    PopvsVac;

-------------------------------------------------------------------------------------------------------------------------------------
-- Find the total number of vaccinations and deaths by location.

SELECT 
    v.location_1 AS location,
    SUM(v.total_vaccinations_1) AS total_vaccinations,
    SUM(d.total_deaths) AS total_deaths
FROM
    Covidvaccinations v
        JOIN
    Coviddeaths d ON v.iso_code_1 = d.iso_code
        AND v.date_1 = d.date
GROUP BY v.location_1;

-------------------------------------------------------------------------------------------------------------------------------------
-- Find the countries where the positive rate is higher than 10% and the total deaths per million exceed 500.

SELECT 
    v.location_1 AS location,
    v.positive_rate_1,
    d.total_deaths_per_million
FROM
    Covidvaccinations v
        JOIN
    Coviddeaths d ON v.iso_code_1 = d.iso_code
        AND v.date_1 = d.date
WHERE
    v.positive_rate_1 > 0.1
        AND d.total_deaths_per_million > 500;

-------------------------------------------------------------------------------------------------------------------------------------
-- Find the continent with the highest average new vaccinations per thousand.

SELECT 
    v.continent_1,
    AVG(v.new_vaccinations_smoothed_per_million_1 / 1000) AS avg_new_vaccinations_per_thousand
FROM
    Covidvaccinations v
GROUP BY v.continent_1
ORDER BY avg_new_vaccinations_per_thousand DESC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------
-- List the top 5 countries with the highest GDP per capita and their total vaccinations.

SELECT 
    v.location_1 AS country,
    v.gdp_per_capita_1,
    SUM(v.total_vaccinations_1) AS total_vaccinations
FROM
    Covidvaccinations v
GROUP BY v.location_1 , v.gdp_per_capita_1
ORDER BY v.gdp_per_capita_1 DESC
LIMIT 5;

-------------------------------------------------------------------------------------------------------------------------------------
-- Identify the date with the highest number of new vaccinations globally.

SELECT 
    v.date_1 AS date,
    SUM(v.new_vaccinations_1) AS total_new_vaccinations
FROM
    Covidvaccinations v
GROUP BY v.date_1
ORDER BY total_new_vaccinations DESC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------
-- Find the average life expectancy and median age of countries where total deaths exceed 10,000.

SELECT 
    AVG(v.life_expectancy_1) AS avg_life_expectancy, 
    AVG(v.median_age_1) AS avg_median_age
FROM 
    Covidvaccinations v
JOIN 
    Coviddeaths d
ON 
    v.iso_code_1 = d.iso_code AND v.date_1 = d.date
WHERE 
    d.total_deaths > 10000;
    
-------------------------------------------------------------------------------------------------------------------------------------
-- List the countries with the highest and lowest stringency index.
-- Highest Stringency Index

SELECT 
    v.location_1 AS country, 
    MAX(v.stringency_index_1) AS max_stringency_index
FROM 
    Covidvaccinations v
GROUP BY 
    v.location_1
ORDER BY 
    max_stringency_index DESC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------
-- Lowest Stringency Index

SELECT 
    v.location_1 AS country, 
    MIN(v.stringency_index_1) AS min_stringency_index
FROM 
    Covidvaccinations v
GROUP BY 
    v.location_1
ORDER BY 
    min_stringency_index ASC
LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------------
-- Find the percentage of fully vaccinated people in countries with a high diabetes prevalence (>10%).

SELECT 
    v.location_1 AS country,
    (SUM(v.people_fully_vaccinated_1) / SUM(d.population) * 100) AS percent_fully_vaccinated
FROM
    Covidvaccinations v
        JOIN
    Coviddeaths d ON v.iso_code_1 = d.iso_code
WHERE
    v.diabetes_prevalence_1 > 10
GROUP BY v.location_1;

-------------------------------------------------------------------------------------------------------------------------------------
-- Compare hospital beds per thousand in the top 5 countries with the most new deaths.

WITH TopDeaths AS (
    SELECT 
        d.location, 
        SUM(d.new_deaths) AS total_new_deaths
    FROM 
        Coviddeaths d
    GROUP BY 
        d.location
    ORDER BY 
        total_new_deaths DESC
    LIMIT 5
)
SELECT 
    td.location, 
    v.hospital_beds_per_thousand_1
FROM 
    TopDeaths td
JOIN 
    Covidvaccinations v
ON 
    td.location = v.location_1
    group by 1,2;
    
-------------------------------------------------------------------------------------------------------------------------------------
-- Identify the top 3 countries with the highest vaccination rates relative to their population, along with their total cases and deaths.

SELECT 
    v.location_1 AS country, 
    (SUM(v.total_vaccinations_1) / d.population * 100) AS vaccination_rate, 
    SUM(d.total_cases) AS total_cases, 
    SUM(d.total_deaths) AS total_deaths
FROM 
    Covidvaccinations v
JOIN 
    Coviddeaths d
ON 
    v.iso_code_1 = d.iso_code AND v.date_1 = d.date
GROUP BY 
    v.location_1, d.population
ORDER BY 
    vaccination_rate DESC
LIMIT 3;

-------------------------------------------------------------------------------------------------------------------------------------
-- Rank continents by their cumulative new deaths and vaccination rates, and show the top 3 for each metric.

WITH ContinentStats AS (
    SELECT 
        v.continent_1 AS continent, 
        SUM(d.new_deaths) AS total_new_deaths, 
        SUM(v.new_vaccinations_1) / SUM(d.population) * 100 AS vaccination_rate
    FROM 
        Covidvaccinations v
    JOIN 
        Coviddeaths d
    ON 
        v.iso_code_1 = d.iso_code AND v.date_1 = d.date
    GROUP BY 
        v.continent_1
),
RankedDeaths AS (
    SELECT 
        continent, 
        total_new_deaths, 
        RANK() OVER (ORDER BY total_new_deaths DESC) AS death_rank
    FROM 
        ContinentStats
),
RankedVaccinations AS (
    SELECT 
        continent, 
        vaccination_rate, 
        RANK() OVER (ORDER BY vaccination_rate DESC) AS vaccination_rank
    FROM 
        ContinentStats
)
SELECT 
    d.continent, 
    d.total_new_deaths, 
    d.death_rank, 
    v.vaccination_rate, 
    v.vaccination_rank
FROM 
    RankedDeaths d
JOIN 
    RankedVaccinations v
ON 
    d.continent = v.continent
WHERE 
    d.death_rank <= 3 OR v.vaccination_rank <= 3;
    
-------------------------------------------------------------------------------------------------------------------------------------
-- Identify countries where the case fatality rate (deaths/cases) significantly exceeds the global average by at least 50%.

WITH GlobalCFR AS (
    SELECT 
        SUM(d.total_deaths) / SUM(d.total_cases) AS global_cfr
    FROM 
        Coviddeaths d
),
CountryCFR AS (
    SELECT 
        d.location AS country, 
        SUM(d.total_deaths) / SUM(d.total_cases) AS country_cfr
    FROM 
        Coviddeaths d
    GROUP BY 
        d.location
)
SELECT 
    cc.country, 
    cc.country_cfr, 
    gc.global_cfr
FROM 
    CountryCFR cc, GlobalCFR gc
WHERE 
    cc.country_cfr > gc.global_cfr * 1.5;
    
-------------------------------------------------------------------------------------------------------------------------------------
-- Analyze vaccination efforts in countries with high hospitalizations (above 500 patients per million).

SELECT 
    v.location_1 AS country, 
    SUM(v.people_vaccinated_1) AS total_people_vaccinated, 
    SUM(v.people_fully_vaccinated_1) AS total_people_fully_vaccinated, 
    AVG(d.hosp_patients_per_million) AS avg_hospitalizations_per_million
FROM 
    Covidvaccinations v
JOIN 
    Coviddeaths d
ON 
    v.iso_code_1 = d.iso_code AND v.date_1 = d.date
WHERE 
    d.hosp_patients_per_million > 500
GROUP BY 
    v.location_1;
    
-------------------------------------------------------------------------------------------------------------------------------------
-- Detect anomalies in case reporting: countries where new cases increased by more than 200% within a day.

WITH DailyIncrease AS (
    SELECT 
        d.location, 
        d.date, 
        d.new_cases, 
        LAG(d.new_cases) OVER (PARTITION BY d.location ORDER BY d.date) AS previous_day_cases
    FROM 
        Coviddeaths d
)
SELECT 
    location, 
    date, 
    new_cases, 
    previous_day_cases, 
    (new_cases - previous_day_cases) / previous_day_cases * 100 AS percent_increase
FROM 
    DailyIncrease
WHERE 
    previous_day_cases > 0 AND (new_cases - previous_day_cases) / previous_day_cases > 2;

-------------------------------------------------------------------------------------------------------------------------------------
-- Compare the ICU usage rates among the top 5 countries with the highest reproduction rate.

WITH TopReproductionRates AS (
    SELECT 
        d.location, 
        AVG(d.reproduction_rate) AS avg_reproduction_rate
    FROM 
        Coviddeaths d
    GROUP BY 
        d.location
    ORDER BY 
        avg_reproduction_rate DESC
    LIMIT 5
)
SELECT 
    tr.location, 
    AVG(d.icu_patients_per_million) AS avg_icu_patients_per_million
FROM 
    TopReproductionRates tr
JOIN 
    Coviddeaths d
ON 
    tr.location = d.location
GROUP BY 
    tr.location;