# SQL Baseball Data Analysis

## Introduction
This project analyzes a baseball dataset to uncover trends in player development, team spending, career longevity, and player demographics. The analysis is conducted using SQL queries across four key areas:

1. **School Contributions**: Identifying top schools producing professional players.
2. **Salary Trends**: Highlighting team spending patterns and financial milestones.
3. **Career Longevity**: Tracking player careers and team loyalty.
4. **Player Comparisons**: Examining birthdates, batting preferences, and physical trends.

### Dataset Overview
- **Tables**: `players`, `salaries`, `schools`, `school_details`.
- **Key Metrics**: Player count, salary sums, career length, height/weight averages.

---

## 1. School Analysis
**Objectives:**
- Identify top schools by player production.
- Analyze trends in player development across decades.

### Key Queries & Results
#### Top 5 Schools by Player Count
SELECT 
    name_full AS university,
    COUNT(DISTINCT playerID) AS players
FROM schools s 
LEFT JOIN school_details sd ON s.schoolID = sd.schoolID
GROUP BY university
ORDER BY players DESC
LIMIT 5;

**Insight:** Schools in California, Texas, and Florida dominate due to robust athletic programs and year-round training climates.

#### Top 3 Schools per Decade
WITH university AS (
    SELECT sd.name_full AS university, sd.city,
           COUNT(DISTINCT(s.playerID)) AS players,
           FLOOR(s.yearID/10)*10 AS decade 
    FROM school_details sd 
    LEFT JOIN schools s ON sd.schoolID = s.schoolID
    WHERE FLOOR(s.yearID/10)*10 IS NOT NULL
    GROUP BY university, sd.city, decade
    ORDER BY decade
),
top_3 AS (
    SELECT university, decade, players,
           DENSE_RANK() OVER(PARTITION BY decade ORDER BY players DESC) AS ranking 
    FROM university
)
SELECT * FROM top_3 WHERE ranking <= 3;


**Insight:** Player production surged post-1960s, reflecting increased investment in college baseball.

---

## 2. Salary Analysis
**Objectives:**
- Identify top-spending teams.
- Track cumulative spending milestones.

### Key Queries & Results
#### Top 20% of Teams by Average Spending
WITH annual_budget AS (
    SELECT yearID, teamID, SUM(salary) AS Team_salary
    FROM salaries
    GROUP BY yearID, teamID
    ORDER BY yearID, Team_salary DESC
),
avg_salary AS (
    SELECT teamID, AVG(Team_salary) AS avg_team_salary,
           NTILE(10) OVER(ORDER BY AVG(Team_salary) DESC) AS spend_pct
    FROM annual_budget
    GROUP BY teamID
)
SELECT teamID,
       CONCAT("$", ROUND(avg_team_salary/1000000,2), " million") AS team_salary
FROM avg_salary
WHERE spend_pct <= 2;

**Insight:** Large-market teams outspend others by 300–400%, correlating with higher revenue and performance.

#### Cumulative Spending Over $1 Billion
WITH team_salary AS (
    SELECT yearID, teamID, SUM(salary) AS salary
    FROM salaries
    GROUP BY yearId, teamId
),
cumulative_table AS (
    SELECT yearID, teamID,
           ROUND(salary/1000000,2) AS salary_millions,
           SUM(salary) OVER(PARTITION BY teamID ORDER BY yearID) AS cumulative_salary
    FROM team_salary
)
SELECT yearID, teamID, team_salary_in_billions
FROM (
    SELECT yearID, teamID,
           ROUND(cumulative_salary/1000000000,2) AS team_salary_in_billions,
           ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY yearID) AS year_rank
    FROM cumulative_table 
    WHERE cumulative_salary >= 1000000000
) rt
WHERE year_rank = 1
ORDER BY yearID;


**Insight:** Top teams reached $1B in cumulative spending by the early 2010s, driven by rising player salaries.

---

## 3. Player Career Analysis
**Objectives:**
- Calculate career lengths and team loyalty.
- Analyze salary progression.

### Key Queries & Results
#### Career Longevity
SELECT 
    playerID, nameGiven,
    TIMESTAMPDIFF(YEAR, debut, finalgame) AS career_length
FROM players
WHERE TIMESTAMPDIFF(YEAR, debut, finalgame) IS NOT NULL
ORDER BY career_length DESC;



- **Longest Career**: 38 years (Nicholas).
- **Average Career**: 6.5 years (excluding players with careers shorter than a year).

**Insight:** Short careers are common, likely due to competitive pressures and injuries.

#### Players with 10+ Years on the Same Team
WITH pt AS (
    SELECT p.playerID, p.namegiven, p.debut,
           s.teamID AS starting_team,
           e.teamID AS ending_team
    FROM players p 
    INNER JOIN salaries s ON p.playerID = s.playerID AND s.yearID = YEAR(p.debut)
    INNER JOIN salaries e ON p.playerID = e.playerID AND e.yearID = YEAR(p.finalGame)
)
SELECT nameGiven, starting_team, ending_team,
       TIMESTAMPDIFF(YEAR, debut, finalgame) AS career_length
FROM pt
WHERE TIMESTAMPDIFF(YEAR, debut, finalgame) >= 10 AND starting_team = ending_team
ORDER BY career_length;

**Insight:** Only 0.14% of players (25 total) stayed with one team for over a decade, highlighting free agency’s impact.

---

## 4. Player Comparison Analysis
**Objectives:**
- Identify shared birthdates.
- Analyze batting preferences and physical trends.

### Key Queries & Results
#### Players Sharing Birthdays
WITH bd AS (
    SELECT playerId, namegiven, 
           CAST(CONCAT_WS('-', birthYear, birthMonth, birthday) AS DATE) AS birthdate 
    FROM players
)
SELECT birthdate, GROUP_CONCAT(CONCAT(playerID,"- ",namegiven) SEPARATOR ", ") AS player_names
FROM bd
WHERE birthdate IS NOT NULL
GROUP BY birthdate
HAVING COUNT(*) > 1
ORDER BY birthdate;

#### Batting Hand Distribution
SELECT teamID,
    ROUND((SUM(CASE WHEN bats = 'R' THEN 1 END)/COUNT(bats)*100),2) AS right_hand_pct,
    ROUND((SUM(CASE WHEN bats = 'L' THEN 1 END)/COUNT(bats)*100),2) AS left_hand_pct,
    ROUND((SUM(CASE WHEN bats = 'B' THEN 1 END)/COUNT(bats)*100),2) AS ambidextrous_pct
FROM players 
GROUP BY teamID;


**Insight:** Right-handed batters dominate, reflecting traditional training focus.

#### Height/Weight Trends Over Decades
WITH decade AS (
				SELECT 
						FLOOR(YEAR(debut)/10)*10 AS debut_decade, 
						AVG(weight) AS avg_weight,
						AVG(height) AS avg_height
				FROM     players
				WHERE    debut is not null
				GROUP BY debut_decade
				ORDER BY debut_decade)
                
SELECT  debut_decade,avg_weight,
		avg_weight - LAG(avg_weight) OVER(ORDER BY debut_decade) AS decade_diff_avgweight,
        avg_height,
        avg_height - LAG(avg_height) OVER(ORDER BY debut_decade) AS decade_diff_avgheight
FROM decade;


---

## 5. Conclusion & Recommendations
### Key Findings
1. **School Impact**: Urban universities in warm climates dominate player pipelines.
2. **Salary Disparities**: Top teams spend 3x more than smaller-market teams.
3. **Career Dynamics**: Short careers are common; loyalty is rare due to free agency.
4. **Physical Evolution**: Players are larger, reflecting modern training standards.

---

## Usage
To run this analysis, ensure you have access to a SQL database containing the relevant tables. Execute the provided queries to reproduce the insights.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

### Notes
- Ensure all images referenced in this README exist in the `/images/` folder within your GitHub repository.
- You may need to update image filenames if they differ from the placeholders used above.

