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

![Screenshot 2025-03-31 100216](https://github.com/user-attachments/assets/54bf8fe8-21ba-4bdf-bdf2-e8acd1081143)

**Result:**

![Screenshot 2025-03-31 100749](https://github.com/user-attachments/assets/dc8199ea-6c72-40d2-b469-972580e74a28)

**Insight:** Schools in California, Texas, and Florida dominate due to robust athletic programs and year-round training climates.

#### Top 3 Schools per Decade

![Screenshot 2025-03-31 110958](https://github.com/user-attachments/assets/14866f18-9e41-4599-991a-72323f52a251)

**Result:**

![Screenshot 2025-03-31 111247](https://github.com/user-attachments/assets/e248162e-a85c-4ee6-bd57-1027f0e2c9d9)


**Insight:** Player production surged post-1960s, reflecting increased investment in college baseball.

---

## 2. Salary Analysis
**Objectives:**
- Identify top-spending teams.
- Track cumulative spending milestones.

### Key Queries & Results
#### Top 20% of Teams by Average Spending

![Screenshot 2025-03-31 112033](https://github.com/user-attachments/assets/6bf2ddaf-be9d-4c44-b3b9-5b8980c031aa)

**Result:**

![Screenshot 2025-03-31 112257](https://github.com/user-attachments/assets/ad3eb91e-7e3f-44c4-8c24-3838d4837087)


**Insight:** Large-market teams outspend others by 200-300%, correlating with higher revenue and performance.

#### Cumulative Spending Over $1 Billion

![Screenshot 2025-03-31 113103](https://github.com/user-attachments/assets/3785df05-1888-4639-b660-2c5a04b80ac7)

**Result:**

![Screenshot 2025-03-31 113245](https://github.com/user-attachments/assets/3a8276d9-9cc5-4907-ab07-904853c6e2e3)

**Insight:** Top teams reached $1B in cumulative spending by the early 2010s, driven by rising player salaries.

---

## 3. Player Career Analysis
**Objectives:**
- Calculate career lengths and team loyalty.
- Analyze salary progression.

### Key Queries & Results
#### Career Longevity

![Screenshot 2025-03-31 123311](https://github.com/user-attachments/assets/c75d3370-5bc8-4bb2-a45f-f9be83edb29e)

**Result:**

![Screenshot 2025-03-31 124203](https://github.com/user-attachments/assets/407287cb-8a01-42b7-88bd-ef406ad107c4)

- **Longest Career**: 35 years (Nicholas).
- **Average Career**: 6.5 years (excluding players with careers shorter than a year).

**Insight:** Short careers are common, likely due to competitive pressures and injuries.

#### Players with 10+ Years on the Same Team

![Screenshot 2025-03-31 130310](https://github.com/user-attachments/assets/7e21306f-ae0d-4b76-a7dc-cd120ccb9f46)

**Result:**

![Screenshot 2025-03-31 130431](https://github.com/user-attachments/assets/c551d853-2d23-47f1-af0a-e0fedcf296ab)

**Insight:** Only 0.14% of players (25 total) stayed with one team for over a decade, highlighting free agency’s impact.

---

## 4. Player Comparison Analysis
**Objectives:**
- Identify shared birthdates.
- Analyze batting preferences and physical trends.

### Key Queries & Results
#### Players Sharing Birthdays

![Screenshot 2025-03-31 131651](https://github.com/user-attachments/assets/72b1e3c9-4f9b-45bd-a5c1-06969fb0dcdd)

**Result:**

![Screenshot 2025-03-31 132011](https://github.com/user-attachments/assets/5b6242d5-3a8a-4646-a416-a78bc3f4af2c)

#### Batting Hand Distribution

![Screenshot 2025-03-31 133343](https://github.com/user-attachments/assets/43108602-31c0-4395-a540-09ea300739e4)

**Result:**

![Screenshot 2025-03-31 133444](https://github.com/user-attachments/assets/bc9e258a-fb5e-41ec-9275-87f9560fa0bb)

**Insight:** Right-handed batters dominate, reflecting traditional training focus.

#### Height/Weight Trends Over Decades

![Screenshot 2025-03-31 133727](https://github.com/user-attachments/assets/98c1a243-6802-4a85-a85e-45c54f910491)

**Result:**

![Screenshot 2025-03-31 133830](https://github.com/user-attachments/assets/df812922-5d5c-4078-bafc-832d06d77863)

---

## 5. Conclusion & Recommendations
### Key Findings
1. **School Impact**: Urban universities in warm climates dominate player pipelines.
2. **Salary Disparities**: Top teams spend 3x more than smaller-market teams.
3. **Career Dynamics**: Short careers are common; loyalty is rare due to free agency.
4. **Physical Evolution**: Players are larger, reflecting modern training standards.

---




