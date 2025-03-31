-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
SELECT * FROM schools;
SELECT * FROM school_details;

-- 2. In each decade, how many schools were there that produced players?
SELECT 
			FLOOR(yearID/10)*10 AS decade,
			COUNT(DISTINCT(schoolID)) AS schools_num 
FROM 		schools
GROUP BY 	decade
order by 	decade; 

-- 3. What are the names of the top 5 schools that produced the most players?
SELECT 
		 name_full AS university,
         COUNT(DISTINCT playerID) AS players
FROM 	 schools s LEFT JOIN school_details sd 
on 		 s.schoolID = sd.schoolID
GROUP BY university
ORDER BY players DESC
LIMIT 5;

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?

with university AS (
					   SELECT 	
								 sd.name_full AS university,sd.city,
								 COUNT(DISTINCT(s.playerID)) AS players,
								 FLOOR(s.yearID/10)*10 AS decade 
						FROM 	 school_details sd LEFT JOIN schools s 
						ON 		 sd.schoolID = s.schoolID
						WHERE 	 FLOOR(s.yearID/10)*10 IS NOT NULL
						GROUP BY university,sd.city,decade
						ORDER BY decade),

top_3 AS  (
			SELECT 
					university,decade,players,
					DENSE_RANK() OVER(PARTITION BY decade ORDER BY players DESC) AS ranking 
			FROM    university) 
                    -- I used dense_rank instead of using rank or row_number because it give me accurate ranking for university which have same number of players 
SELECT * 
FROM top_3
WHERE ranking <= 3;

-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
SELECT * FROM salaries;

-- 2. Return the top 20% of teams in terms of average annual spending

WITH annual_budget AS
(SELECT 		yearID, teamID, SUM(salary) AS Team_salary
 FROM 		salaries
 GROUP BY 	yearID,teamID
 ORDER BY 	yearID,Team_salary DESC),
 
 avg_salary As (SELECT 
						teamID,AVG(Team_salary) AS avg_team_salary,
						NTILE(10) OVER(ORDER BY AVG(Team_salary) DESC) AS spend_pct
			    FROM annual_budget
			    GROUP BY teamID)
               
SELECT 
        teamID,
        concat("$",ROUND(avg_team_salary/1000000,2)," million") AS team_salary
FROM avg_salary
WHERE spend_pct <=2; -- to get top 20% of team salary, we coul have also used rank_percemt()

-- 3. For each team, show the cumulative sum of spending over the years

WITH team_salary AS (
					  SELECT yearID,teamID,SUM(salary) AS salary
                      FROM salaries
                      GROUP BY yearId,teamId)

SELECT yearID,teamID,
	   ROUND(salary/1000000,2) AS salary_millions,
	   ROUND((SUM(salary) OVER(PARTITION BY teamID ORDER BY yearID))/1000000,2) AS cumulative_salary_millions
FROM   team_salary;


-- 4. Return the first year that each team's cumulative spending surpassed 1 billion

WITH team_salary AS (
					  SELECT yearID,teamID,SUM(salary) AS salary
                      FROM salaries
                      GROUP BY yearId,teamId),

cumulative_table AS (SELECT yearID,teamID,
							ROUND(salary/1000000,2) AS salary_millions,
							SUM(salary) OVER(PARTITION BY teamID ORDER BY yearID) AS cumulative_salary
							FROM   team_salary)

SELECT 
		yearID,teamID,team_salary_in_billions
FROM 
		(SELECT yearID,teamID,
		 ROUND(cumulative_salary/1000000000,2) AS team_salary_in_billions,
		 row_number() OVER(PARTITION BY teamID ORDER BY yearID) AS year_rank
		 FROM   cumulative_table 
		 WHERE  cumulative_salary >= 1000000000) rt
WHERE year_rank = 1
ORDER BY yearId;

-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
SELECT * FROM players;
-- number of players
SELECT COUNT(DISTINCT playerID) AS num_of_players
FROM players;

-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
SELECT 
			playerID,nameGiven,
            CAST(CONCAT_WS("-",birthYear,birthMonth,birthday) AS DATE) AS birthdate,
            TIMESTAMPDIFF(YEAR,CAST(CONCAT_WS("-",birthYear,birthMonth,birthday) AS DATE),debut) AS debut_yr_age,
            TIMESTAMPDIFF(YEAR,CAST(CONCAT_WS("-",birthYear,birthMonth,birthday)AS DATE),finalGame) AS retired_yr_age,
            TIMESTAMPDIFF(YEAR,debut,finalgame) AS career_length
            
FROM 		players
WHERE 		TIMESTAMPDIFF(YEAR,debut,finalgame) IS NOT NULL
ORDER BY 	career_length DESC;

-- Average and longest career

SELECT 
		AVG(career_length) AS average_career, 
        MAX(career_length) AS longest_career
FROM    (SELECT 
				playerID,nameGiven,
				CAST(CONCAT_WS("-",birthYear,birthMonth,birthday) AS DATE) AS birthdate,
				TIMESTAMPDIFF(YEAR,CAST(CONCAT_WS("-",birthYear,birthMonth,birthday) AS DATE),debut) AS debut_yr_age,
				TIMESTAMPDIFF(YEAR,CAST(CONCAT_WS("-",birthYear,birthMonth,birthday)AS DATE),finalGame) AS retired_yr_age,
				TIMESTAMPDIFF(YEAR,debut,finalgame) AS career_length
            
		 FROM 		players
		WHERE 		TIMESTAMPDIFF(YEAR,debut,finalgame) IS NOT NULL AND TIMESTAMPDIFF(YEAR,debut,finalgame) >0
		ORDER BY 	career_length DESC) t;


-- 3. What team did each player play on for their starting and ending years and what their salary?

SELECT  p.playerID,p.debut,
		s.yearID AS starting_year,
        s.teamID AS starting_team,
        s.salary AS starting_salary,
        p.finalGame,e.yearID AS ending_year,
        e.teamID AS ending_team,e.salary AS ending_salary
		FROM 	players p INNER JOIN salaries s 
						  ON  p.playerID = s.playerID 
                          AND s.yearID = YEAR(p.debut)
				  INNER JOIN salaries e 
						  ON  p.playerID = e.playerID 
                          AND e.yearID = YEAR(p.finalGame);
		
-- 4. How many players started and ended on the same team and also played for over a decade?

WITH pt AS
(SELECT  p.playerID,p.namegiven,p.debut,
		s.yearID AS starting_year,
        s.teamID AS starting_team,
        p.finalGame,e.yearID AS ending_year,
        e.teamID AS ending_team
		FROM 	players p INNER JOIN salaries s 
						  ON  p.playerID = s.playerID 
                          AND s.yearID = YEAR(p.debut)
				  INNER JOIN salaries e 
						  ON  p.playerID = e.playerID 
                          AND e.yearID = YEAR(p.finalGame))

SELECT  nameGiven, 
		starting_year,starting_team,
        ending_year,ending_team,
        TIMESTAMPDIFF(YEAR,debut,finalgame) AS career_length
from    pt
WHERE   TIMESTAMPDIFF(YEAR,debut,finalgame) >= 10  
		AND starting_team = ending_team
ORDER BY career_length;


-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table

 SELECT * FROM players;

-- 2. Which players have the same birthday?
-- Slow method self join
WITH bd AS (
    SELECT playerId, namegiven, 
           CAST(CONCAT_WS('-', birthYear, birthMonth, birthday) AS DATE) AS birthdate 
    FROM players
)
SELECT 
    p1.playerID AS p1_ID, 
    p1.namegiven AS p1_name, 
    p1.birthdate AS p1_birthdate,
    p2.playerID AS p2_ID, 
    p2.namegiven AS p2_name, 
    p2.birthdate AS p2_birthdate
FROM bd p1 
INNER JOIN bd p2 
    ON p1.birthdate = p2.birthdate
    AND p1.playerID > p2.playerID;
    
-- Faster method 

WITH bd AS (
    SELECT playerId, namegiven, 
           CAST(CONCAT_WS('-', birthYear, birthMonth, birthday) AS DATE) AS birthdate 
    FROM players)
    
SELECT birthdate, (GROUP_CONCAT(CONCAT(playerID,"- ",namegiven) SEPARATOR ", ")) AS player_names FROM bd
WHERE birthdate IS NOT NULL
GROUP BY birthdate
HAVING COUNT(*) > 1
ORDER BY birthdate;

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both

SELECT 		s.teamID,
			ROUND((SUM(CASE WHEN p.bats = "R" THEN 1 END)/COUNT(p.bats)*100 ),2)AS right_hand_pct,
			ROUND((SUM(CASE WHEN p.bats = "L" THEN 1 END)/COUNT(p.bats)*100),2) AS left_hand_pct,
			ROUND((SUM(CASE WHEN p.bats = "B" THEN 1 END)/COUNT(p.bats)*100),2) AS ambidextrous_pct
FROM 		players p LEFT JOIN salaries s 
ON 			p.playerID = s.playerID
GROUP BY 	s.teamID;


-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?


WITH debut AS (
				SELECT 
						 YEAR(debut) AS debut_year, 
						 AVG(weight) AS avg_weight,
						 AVG(height) AS avg_height
				FROM     players
				WHERE    debut is not null
				GROUP BY debut_year
				ORDER BY debut_year)
                
SELECT debut_year,avg_weight,
		avg_weight - LAG(avg_weight) OVER(ORDER BY debut_year) AS yoy_diff_avgweight,
        avg_height,
        avg_height - LAG(avg_height) OVER(ORDER BY debut_year) AS yoy_diff_avgheight
FROM debut; -- year over year difference in weight and height

-- decade-overdecade difference in weight and height


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

					

