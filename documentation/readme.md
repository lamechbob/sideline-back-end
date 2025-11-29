# 🐾 South Broward Football – Backend (AWS + Postgres)

This repository contains the backend infrastructure for **Project Sideline**, the South Broward High School football statistics system.  
It includes AWS Lambda functions for importing and managing data, plus the SQL logic powering the Streamlit dashboard.

---

## 🚀 Overview

The backend consists of:

- **Postgres Database** (hosted on AWS RDS – now archived)  
- **4 AWS Lambda Functions** for importing schedules, rosters, and weekly game stats  
- **Database Migration Script** to initialize schema  
- **A Season Summary SQL View** that aggregates all player statistics for consumption by the Streamlit dashboard  

This backend powers the stat-tracking workflow for an entire football season.

---

## 🏗️ Architecture Summary

- **Storage:** Amazon RDS Postgres  
- **Compute:** AWS Lambda (Python-based import scripts)  
- **Source Files:** Excel templates for structured data entry  
- **Analytics Layer:** SQL view → Exported to CSV → Consumed by Streamlit  

---

## 📁 Repository Structure

    .
    ├── lambdas/
    │   ├── sbhs-schedule-import/
    │   ├── sbhs-game-stats-import/
    │   ├── sbhs-db-migrate/
    │   └── sbhs-roster-import/
    ├── sql/
    │   └── season_summary_view.sql
    ├── templates/
    │   ├── roster_template.xlsx
    │   ├── game_stats_template.xlsx
    │   └── schedule_template.xlsx   (if applicable)
    └── README.md


---

# 🧩 Lambda Functions

Below is a breakdown of each Lambda, when to use it, and what it updates.

---

## 1️⃣ sbhs-db-migrate  
**Purpose:** Initialize the database.  
**Run this first.**

This Lambda creates all required tables (Teams, Players, Games, GameStats, etc.).  
It must be executed **before** importing any rosters, schedules, or game stats.

---

## 2️⃣ sbhs-schedule-import  
**Purpose:** Import the season schedule.  
**Order:** Run *after* DB migration, and *before* any game stats.

- Reads: `schedule_template.xlsx`  
- Inserts the full season schedule  
- Automatically adds all opponents into the **Team** table  
- Creates game entries for tracking future stats

---

## 3️⃣ sbhs-roster-import  
**Purpose:** Import the team roster.  
**Order:** Must be run before importing any game stats.

- Reads: `roster_template.xlsx`  
- Inserts player records for the season  
- Updates the **Player** and related tables  
- Supports jersey changes, player metadata, and roster overrides

---

## 4️⃣ sbhs-game-stats-import  
**Purpose:** Import weekly game stats captured from the sideline.

- Reads: `game_stats_template.xlsx`  
- Inserts play-by-play or aggregate stats  
- Supports tackles, sacks, rushing, passing, receiving, TFLs, and more  
- Designed for fast entry and accurate ingestion  

This Lambda is run **once per game** for all stat categories.

---

# 🗂️ Filename Requirements (Strict Validation Rules)

Each Lambda function requires uploaded Excel files to follow **strict, predictable filename patterns**.  
If the filename does not meet these rules, the Lambda will **reject the file** before processing.

These rules prevent incorrect imports and ensure data integrity.

---

## 📅 sbhs-schedule-import  
### Required Filename Pattern
YYYY_Team_Name_Roster.xlsx


### Rules
- Must begin with a **4-digit year** (e.g., `2025_…`)
- Must contain a final segment **"_Roster"**
- Team name is everything between the year and `_Roster`
- Team names may use underscores or hyphens (converted automatically)
- Year must be between **2000–2100**

### Examples — ✅ Valid
2025_South_Broward_Roster.xlsx
2024_Miami-Northwestern_Roster.xlsx


### Examples — ❌ Invalid
South_Broward_Roster.xlsx
25_South_Broward_Roster.xlsx
2025_South_Broward.xlsx
2025__Roster.xlsx


---

## 🧍 sbhs-roster-import  
### Required Filename Pattern
**Same rules as sbhs-schedule-import**

YYYY_Team_Name_Roster.xlsx

### Notes
Both functions use the **exact same validation logic**, ensuring the roster and schedule follow identical naming standards.

---

## 🏈 sbhs-game-stats-import  
### Required Filename Pattern
Two valid patterns are allowed:

GameID_Team_Name_GameStats.xlsx
GameID_Team_Name_Game_Stats.xlsx


### Rules
- First token must be an **integer GameID**
- Filename must end with either:
  - `_GameStats`
  - `_Game_Stats`
- Team name is everything between `GameID` and the `_GameStats` segment
- Team names may use underscores or hyphens (converted automatically)

### Examples — ✅ Valid
42_South_Broward_GameStats.xlsx
42_South_Broward_Game_Stats.xlsx
108_Miami-Norland_GameStats.xlsx


### Examples — ❌ Invalid
South_Broward_GameStats.xlsx
42_South_Broward.xlsx
42__GameStats.xlsx
42_South_Broward_Gamestats.xlsx


---

## 📝 Returned Metadata
Each parser returns the extracted metadata:

| Lambda                     | Returns                      |
|---------------------------|------------------------------|
| sbhs-schedule-import      | `(season:int, team:str)`     |
| sbhs-roster-import        | `(season:int, team:str)`     |
| sbhs-game-stats-import    | `(game_id:int, team:str)`    |

This metadata is used for inserting data into the correct season, game, or team tables.

---

# 📊 SQL: Season Summary View

**File:** `season_summary_view.sql`  
**Purpose:** Generate the roll-up statistics used by the Streamlit dashboard.

The view:

- Aggregates all stats **per player per week**  
- Calculates season totals  
- Produces a clean dataset for exporting to CSV  
- Serves as the backbone for the Streamlit UI

Example metrics included:

- Rushing / Passing / Receiving  
- Tackles, Sacks, Tackles for Loss  
- Return stats  
- Special teams  
- Week-over-week cumulative totals  

This view is executed outside of Lambda and the results are exported as a CSV, which the dashboard consumes.

---

# 🏁 Import Order (Very Important)

To avoid errors and ensure referential integrity:

1. **Run `sbhs-db-migrate`**  
2. **Run `sbhs-schedule-import`**  
3. **Run `sbhs-roster-import`**  
4. **Run `sbhs-game-stats-import`** (weekly)  
5. **Generate / refresh the Season Summary View** and export CSV  
6. **Upload CSV to the Streamlit dashboard repo**

---

# 📦 Excel Templates

Data entry is standardized using pre-defined Excel templates:

- `roster_template.xlsx` → For roster imports  
- `game_stats_template.xlsx` → For weekly stats  
- `schedule_template.xlsx` (if applicable) → For initial schedule  

These templates ensure consistent column names and prevent ingestion errors.

---

# 🔧 Configuration

Each Lambda uses environment variables to access:

- Database host  
- Username  
- Password  
- Port  
- Schema  

Credentials were managed via AWS Secrets Manager or Lambda environment variables.

---

# 📚 Future Enhancements

Potential upgrades:

- Migrate to Aurora Serverless (Postgres)  
- Automate CSV export with an S3 trigger + Lambda  
- Daily/weekly stat refresh workflows using Step Functions  
- Streamlit API endpoints instead of CSV  
- Add player awards + image generation (planned)

---

