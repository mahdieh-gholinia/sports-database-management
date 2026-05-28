
DROP DATABASE IF EXISTS sports_db;
CREATE DATABASE sports_db;
USE sports_db;

-- Sport
CREATE TABLE Sport (
    SportID INT PRIMARY KEY AUTO_INCREMENT,
    SportName VARCHAR(100) NOT NULL UNIQUE,
    Category ENUM('Team', 'Individual') NOT NULL
);

-- Team
CREATE TABLE Team (
    TeamID INT PRIMARY KEY AUTO_INCREMENT,
    SportID INT,
    TeamName VARCHAR(100) NOT NULL UNIQUE,
    FoundedYear INT CHECK (FoundedYear BETWEEN 1800 AND 2025),
    HomeCity VARCHAR(100),
    FOREIGN KEY (SportID) REFERENCES Sport(SportID) ON DELETE RESTRICT
);

-- Athlete
CREATE TABLE Athlete (
    AthleteID INT PRIMARY KEY AUTO_INCREMENT,
    SportID INT,
    TeamID INT DEFAULT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Birthdate DATE NOT NULL,
    Gender ENUM('Male', 'Female') NOT NULL,
    Nationality VARCHAR(100) NOT NULL,
    Rating INT CHECK (Rating BETWEEN 0 AND 100),
    FOREIGN KEY (SportID) REFERENCES Sport(SportID) ON DELETE RESTRICT,
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE SET NULL
);

-- Coach
CREATE TABLE Coach (
    CoachID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Experience INT
);

-- Coach_Assignment 
CREATE TABLE Coach_Assignment (
    AssignmentID INT PRIMARY KEY AUTO_INCREMENT,
    CoachID INT,
    TeamID INT,
    UNIQUE (CoachID, TeamID),
    FOREIGN KEY (CoachID) REFERENCES Coach(CoachID) ON DELETE CASCADE,
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE
);

-- Discipline
CREATE TABLE Discipline (
    DisciplineID INT PRIMARY KEY AUTO_INCREMENT,
    DisciplineName VARCHAR(100) NOT NULL,
    SportID INT,
    FOREIGN KEY (SportID) REFERENCES Sport(SportID) ON DELETE RESTRICT
);

-- Tournament
CREATE TABLE Tournament (
    TournamentID INT PRIMARY KEY AUTO_INCREMENT,
    TournamentName VARCHAR(100) NOT NULL,
    SportID INT,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Location VARCHAR(100) NOT NULL,
    FOREIGN KEY (SportID) REFERENCES Sport(SportID) ON DELETE RESTRICT,
    CONSTRAINT check_dates CHECK (EndDate > StartDate)
);

-- Venue
CREATE TABLE Venue (
    VenueID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0)
);

-- Referee
CREATE TABLE Referee (
    RefereeID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(100) NOT NULL,
    Qualification VARCHAR(100) NOT NULL,
    SportID INT,
    FOREIGN KEY (SportID) REFERENCES Sport(SportID) ON DELETE RESTRICT
);

-- Match
CREATE TABLE `Match` (
    MatchID INT PRIMARY KEY AUTO_INCREMENT,
    TournamentID INT,
    VenueID INT,
    RefereeID INT NOT NULL,
    MatchDate DATE NOT NULL,
    MatchTime TIME,
    FOREIGN KEY (TournamentID) REFERENCES Tournament(TournamentID) ON DELETE RESTRICT,
    FOREIGN KEY (VenueID) REFERENCES Venue(VenueID) ON DELETE RESTRICT,
    FOREIGN KEY (RefereeID) REFERENCES Referee(RefereeID) ON DELETE RESTRICT
);

-- Match_Teams
CREATE TABLE Match_Teams (
    MatchID INT,
    TeamID INT,
    Role ENUM('Home', 'Away') NOT NULL,
    PRIMARY KEY (MatchID, TeamID),
    FOREIGN KEY (MatchID) REFERENCES `Match`(MatchID) ON DELETE CASCADE,
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE CASCADE
);

-- Event_Log 
CREATE TABLE Event_Log (
    EventID INT PRIMARY KEY AUTO_INCREMENT,
    MatchID INT,
    AthleteID INT,
    TeamID INT,
    EventType VARCHAR(100) NOT NULL,
    EventTime TIME NOT NULL,
    Description TEXT,
    FOREIGN KEY (MatchID) REFERENCES `Match`(MatchID) ON DELETE CASCADE,
    FOREIGN KEY (AthleteID) REFERENCES Athlete(AthleteID) ON DELETE CASCADE,
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE SET NULL
);

-- Performance 
CREATE TABLE Performance (
    PerformanceID INT PRIMARY KEY AUTO_INCREMENT,
    AthleteID INT,
    MatchID INT,
    Goals INT,
    Assists INT,
    FOREIGN KEY (AthleteID) REFERENCES Athlete(AthleteID) ON DELETE CASCADE,
    FOREIGN KEY (MatchID) REFERENCES `Match`(MatchID) ON DELETE CASCADE
);

-- Award
CREATE TABLE Award (
    AwardID INT PRIMARY KEY AUTO_INCREMENT,
    AthleteID INT,
    TeamID INT,
    TournamentID INT,
    AwardName VARCHAR(100) NOT NULL,
    AwardDate DATE NOT NULL,
    FOREIGN KEY (AthleteID) REFERENCES Athlete(AthleteID) ON DELETE CASCADE,
    FOREIGN KEY (TeamID) REFERENCES Team(TeamID) ON DELETE RESTRICT,
    FOREIGN KEY (TournamentID) REFERENCES Tournament(TournamentID) ON DELETE RESTRICT,
    CONSTRAINT check_award_recipient CHECK (
        (AthleteID IS NOT NULL AND TeamID IS NULL) OR
        (AthleteID IS NULL AND TeamID IS NOT NULL)
    )
);

DROP USER IF EXISTS 'user1'@'localhost';
DROP USER IF EXISTS 'user1'@'%';
CREATE USER 'user1'@'localhost' IDENTIFIED BY 'user1pass';

-- اعطای دسترسی‌
GRANT SELECT, INSERT ON sports_db.Sport TO 'user1'@'localhost';
GRANT SELECT, INSERT ON sports_db.Team TO 'user1'@'localhost';
GRANT SELECT ON sports_db.Athlete TO 'user1'@'localhost';
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'user1'@'localhost';

-- درج داده‌های نمونه
-- Sport
INSERT INTO Sport (SportName, Category) VALUES
('Football', 'Team'),
('Volleyball', 'Team'),
('Tennis', 'Individual'),
('Swimming', 'Individual'),
('Boxing', 'Individual'),
('Athletics', 'Individual');

-- Team
INSERT INTO Team (SportID, TeamName, FoundedYear, HomeCity) VALUES
(1, 'Perspolis', 1963, 'Tehran'),
(1, 'Esteghlal', 1945, 'Tehran'),
(2, 'Tehran Volleyball', 1980, 'Tehran'),
(2, 'Shiraz Spikers', 1990, 'Shiraz');

-- Athlete
INSERT INTO Athlete (SportID, TeamID, FirstName, LastName, Birthdate, Gender, Nationality, Rating) VALUES
(1, 1, 'Ali', 'Alipour', '1995-11-11', 'Male', 'Iranian', 85),
(1, 2, 'Hossein', 'Hosseini', '1992-06-30', 'Male', 'Iranian', 80),
(2, 3, 'Sara', 'Ahmadi', '1993-03-15', 'Female', 'Iranian', 78),
(2, 4, 'Mohammad', 'Rezaei', '1990-08-22', 'Male', 'Iranian', 82),
(3, NULL, 'Hamed', 'Haddadi', '1985-05-19', 'Male', 'Iranian', 90),
(4, NULL, 'Maryam', 'Hashemi', '1998-02-10', 'Female', 'Iranian', 88),
(5, NULL, 'Ehsan', 'Ghaemmaghami', '1994-12-01', 'Male', 'Iranian', 85),
(6, NULL, 'Leila', 'Rajabi', '1983-04-18', 'Female', 'Iranian', 87);

-- Coach
INSERT INTO Coach (FirstName, LastName, Experience) VALUES
('Yahya', 'GolMohammadi', 15),
('Narges', 'Mohammadi', 10),
('Reza', 'Salehi', 8),
('Fatemeh', 'Karimi', 12);

-- Coach_Assignment
INSERT INTO Coach_Assignment (CoachID, TeamID) VALUES
(1, 1),
(2, 3);

-- Discipline
INSERT INTO Discipline (DisciplineName, SportID) VALUES
('Freestyle Swimming', 4),
('Singles Tennis', 3),
('100m Sprint', 6),
('Lightweight Boxing', 5);

-- Tournament
INSERT INTO Tournament (TournamentName, SportID, StartDate, EndDate, Location) VALUES
('Persian Gulf Pro League', 1, '2025-08-01', '2026-05-30', 'Tehran'),
('Iran Volleyball League', 2, '2025-09-01', '2026-03-15', 'Shiraz'),
('Tehran Open Tennis', 3, '2025-07-01', '2025-07-15', 'Tehran'),
('National Swimming Championship', 4, '2025-06-01', '2025-06-10', 'Isfahan');

-- Venue
INSERT INTO Venue (Name, Address, Capacity) VALUES
('Azadi Stadium', 'Tehran, Azadi Blvd', 78000),
('Shiraz Volleyball Arena', 'Shiraz, Hafez St', 5000),
('Tehran Tennis Club', 'Tehran, North Kargar St', 2000),
('Isfahan Aquatic Center', 'Isfahan, Enghelab St', 3000);

-- Referee
INSERT INTO Referee (FirstName, Qualification, SportID) VALUES
('Alireza', 'FIFA Certified', 1),
('Zahra', 'National Certified', 2),
('Kaveh', 'ITF Certified', 3);

-- Match
INSERT INTO `Match` (TournamentID, VenueID, RefereeID, MatchDate, MatchTime) VALUES
(1, 1, 1, '2025-08-10', '15:00:00'),
(2, 2, 2, '2025-09-10', '18:00:00'),
(3, 3, 3, '2025-07-05', NULL),
(4, 4, 1, '2025-06-05', NULL);

-- Match_Teams
INSERT INTO Match_Teams (MatchID, TeamID, Role) VALUES
(1, 1, 'Home'), -- Perspolis
(1, 2, 'Away'), -- Esteghlal
(2, 3, 'Home'), -- Tehran Volleyball
(2, 4, 'Away'); -- Shiraz Spikers

-- Event_Log
INSERT INTO Event_Log (MatchID, AthleteID, TeamID, EventType, EventTime, Description) VALUES
(1, 1, 1, 'Goal', '00:45:00', 'Ali Alipour scored a goal'),
(2, 3, 3, 'Point', '00:01:20', 'Sara Ahmadi scored a point'),
(3, 5, NULL, 'Win', '02:00:00', 'Hamed Haddadi won the match');

-- Performance
INSERT INTO Performance (AthleteID, MatchID, Goals, Assists) VALUES
(1, 1, 1, 0),
(3, 2, 0, 2),
(5, 3, 0, 0);

-- Award
INSERT INTO Award (AthleteID, TeamID, TournamentID, AwardName, AwardDate) VALUES
(1, NULL, 1, 'Best Player', '2025-08-15'),
(5, NULL, 3, 'Champion', '2025-07-15'),
(NULL, 3, 2, 'Best Team', '2025-09-20');

-- کوئری‌های نمونه برای کار با دیتابیس
-- 1. 
SELECT * FROM Sport;

-- 2. 
SELECT FirstName, LastName FROM Athlete WHERE SportID = 1;

-- 3. 
SELECT a.FirstName, a.LastName, t.TeamName, s.SportName
FROM Athlete a
LEFT JOIN Team t ON a.TeamID = t.TeamID
JOIN Sport s ON a.SportID = s.SportID;

-- 4. 
SELECT s.SportName, COUNT(a.AthleteID) AS AthleteCount
FROM Sport s
LEFT JOIN Athlete a ON s.SportID = a.SportID
GROUP BY s.SportName;

-- 5. 
UPDATE Athlete SET Rating = 90 WHERE AthleteID = 1;

-- 6. 
DELETE FROM Athlete WHERE AthleteID = 7; 

-- 7. 
SELECT m.MatchID, t.TournamentName, v.Name AS VenueName, r.FirstName AS RefereeName, s.SportName
FROM `Match` m
JOIN Tournament t ON m.TournamentID = t.TournamentID
JOIN Venue v ON m.VenueID = v.VenueID
JOIN Referee r ON m.RefereeID = r.RefereeID
JOIN Sport s ON t.SportID = s.SportID;

-- 8. 
SELECT a.FirstName, a.LastName, p.Goals, p.Assists, m.MatchDate
FROM Performance p
JOIN Athlete a ON p.AthleteID = a.AthleteID
JOIN `Match` m ON p.MatchID = m.MatchID;

-- 9. 
SELECT c.FirstName, c.LastName, t.TeamName
FROM Coach_Assignment ca
JOIN Coach c ON ca.CoachID = c.CoachID
JOIN Team t ON ca.TeamID = t.TeamID;

-- 10. 
SELECT m.MatchID, t.TeamName, mt.Role
FROM Match_Teams mt
JOIN Team t ON mt.TeamID = t.TeamID
JOIN `Match` m ON mt.MatchID = m.MatchID;

-- 11. 
SELECT a.AwardName, t.TournamentName, ath.FirstName, ath.LastName, tm.TeamName
FROM Award a
LEFT JOIN Athlete ath ON a.AthleteID = ath.AthleteID
LEFT JOIN Team tm ON a.TeamID = tm.TeamID
JOIN Tournament t ON a.TournamentID = t.TournamentID;

