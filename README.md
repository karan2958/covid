# COVID-19 Data SQL Exploration 🏥

**Hello Readers**  
I sourced this dataset from Kaggle and loaded it into a SQL database to perform a full exploratory analysis using plain SQL. In the first part of the workflow, you’ll see how to import and **clean** the raw data—an essential step before any querying. Then, in **SQL Covid.sql**, I’ve written queries that demonstrate everything from basic aggregates to window functions, helping you uncover trends and insights in the COVID-19 data.

---

## 📖 Table of Contents

1. [About](#about)  
2. [Dataset](#dataset)  
3. [Data Cleaning & Preparation](#data-cleaning--preparation)  
4. [SQL Analysis](#sql-analysis)  
5. [Prerequisites](#prerequisites)  
6. [Setup & Usage](#setup--usage)  
7. [Project Structure](#project-structure)  
8. [Next Steps](#next-steps)  
9. [License](#license)  
10. [Contact](#contact)  

---

## 🔍 About

This project explores COVID-19 case data for India using only SQL. You’ll learn how to load a CSV into your database, clean and standardize fields, then write queries to:

- Summarize total cases, recoveries, and deaths  
- Track daily and monthly trends  
- Identify the hardest-hit states and dates  
- Compute growth rates with window functions  
- Rank regions by case counts  

All queries live in the [SQL Covid.sql](https://github.com/karan2958/covid/blob/main/SQL%20Covid.sql) script.

---

## 📂 Dataset

- **Key fields** include:  
  - `Date`: observation date (YYYY-MM-DD)  
  - `State`: Indian state or union territory  
  - `Confirmed`: cumulative confirmed cases  
  - `Recovered`: cumulative recoveries  
  - `Deaths`: cumulative fatalities  
  - …and other metadata columns

---

## 🧹 Data Cleaning & Preparation

1. **Import** raw CSV into a staging table.  
2. **Trim** whitespace and **CAST** strings to dates and numbers.  
3. **Filter** out duplicates and NULLs.  
4. **Create** a final cleaned table for analysis.

_Clean data ensures accurate aggregates and window calculations!_

---

## ✨ SQL Analysis

In **SQL Covid.sql**, you’ll find queries such as:

- **Descriptive Aggregates**:  
```  SELECT Date,
         SUM(Confirmed)   AS total_confirmed,
         SUM(Recovered)   AS total_recovered,
         SUM(Deaths)      AS total_deaths
    FROM covid_clean
   GROUP BY Date;
