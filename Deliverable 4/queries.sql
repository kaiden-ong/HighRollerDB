USE HighRollerDB
GO

-- Kaiden's queries
/*
 Write the SQL code to create two (2) stored procedures, one for updating data,
 and the second one for deleting a row of data.  Create two (2) associated triggers,
 one to log update operations of your update stored procedure, and the other to log
 delete operations of your delete stored procedure.
*/
-- updating a row in jackpot table
/*
This query is used for updating the amount a jackpot is worth.
It takes in parameters of the jackpot id and dollar amount, using these to update
the corresponding jackpot with the new jackpot amount.
This query will be used often to update the jackpot whenever it increases (or decreases).
*/
CREATE OR ALTER PROCEDURE ko_sp_UpdateJackpot
	(@jackpot_id INT, @new_jackpot INT)
AS
BEGIN
	IF @jackpot_id NOT IN (SELECT jackpot_id FROM jackpots)
		THROW 50001, 'Invalid input. That jackpot ID does not exist in the jackpots table', 1
	ELSE
		UPDATE jackpots
		SET amount = @new_jackpot
		WHERE jackpot_id = @jackpot_id
END
GO

--testing sp, changing jackpot_id 3 to $30,000
SELECT * FROM jackpots
EXEC ko_sp_UpdateJackpot @jackpot_id=3, @new_jackpot=30000
GO

--fail 
EXEC ko_sp_UpdateJackpot @jackpot_id=100000, @new_jackpot=30000
GO

-- deleting a row from the players table
/*
The purpose of this query is to delete a player from the players table.
It takes in a player id and uses that to remove the row that correlates to that player.
This is an important query because it's necessary to track players with an up-to-date list,
so if a player is no longer needed in the system (they delete their membership/account), the 
row is no longer needed.
*/
CREATE OR ALTER PROCEDURE ko_sp_DeletePlayerRow
	(@player_id INT)
AS
BEGIN
	IF @player_id NOT IN (SELECT player_id FROM players)
		THROW 50001, 'Invalid input. That player ID does not exist in the players table', 1
	ELSE
		DELETE FROM players
            WHERE player_id = @player_id;
		print(CONCAT(@player_id, ' has been removed from the players db'))
END
GO

-- testing sp, removing player id 1001 from players table
SELECT * FROM players ORDER BY player_id DESC
EXEC ko_sp_DeletePlayerRow @player_id=1001
GO

--fail
EXEC ko_sp_DeletePlayerRow @player_id=100000
GO

-- trigger logging update operations
/*
Create a log table for jackpot updates
*/
CREATE TABLE ko_jackpot_log(jackpot_id INT,
							player_id VARCHAR(60),
							amount INT,
							log_time DATETIME,
							log_action VARCHAR(60))
GO

/*
This trigger's purpose is to update the jackpot update table with a log
whenever a jackpot "amount" row is changed. It's important to keep this up to date
so this trigger is important and will be used often, as jackpots change often.
*/
CREATE OR ALTER TRIGGER ko_tr_LogJackpotUpdate
	ON jackpots
	AFTER UPDATE
AS
BEGIN
	DECLARE @LogTime DATETIME = GETDATE();
    DECLARE @LogAction VARCHAR(60) = 'Jackpot amount update';
    INSERT INTO ko_jackpot_log (jackpot_id, player_id, amount, log_time, log_action)
    SELECT i.jackpot_id, i.player_id, i.amount, @LogTime, @LogAction
    FROM inserted AS i;
END 
GO

--testing, checking to see if update from earlier created a log
SELECT * FROM ko_jackpot_log
GO

-- trigger logging delete operations
/*
Create a log table for player updates
*/
CREATE TABLE ko_player_log(player_id INT,
							first_name VARCHAR(50),
							last_name VARCHAR(500),
							phone VARCHAR(20),
							email VARCHAR(50),
							dob DATE,
							join_date DATE,
							total_sessions INT,
							log_time DATETIME,
							log_action VARCHAR(60))
GO

/*
This trigger's purpose is to update the jackpot update table with a log
whenever a player row is deleted. An up to date list of players is necessary
to effectively manage a casino.
*/
CREATE OR ALTER TRIGGER ko_tr_LogPlayerDelete
	ON players
	AFTER DELETE
AS
BEGIN
	DECLARE @LogTime DATETIME = GETDATE();
    DECLARE @LogAction VARCHAR(60) = 'Player row deleted';
    INSERT INTO ko_player_log (player_id, first_name, last_name, phone, email, dob,
								join_date, total_sessions, log_time, log_action)
    SELECT d.player_id, d.first_name, d.last_name, d.phone_number, d.email, d.date_of_birth,
		d.join_date, d.total_sessions, @LogTime, @LogAction
    FROM deleted AS d;
END 
GO

--testing, checking to see if deletion from earlier created a log
SELECT * FROM ko_player_log
GO

 /* 
 Write the SQL code to create one (1) trigger that implements a business logic or a business rule.
*/
-- Business rule: prevent players under 21 from joining
/*
The purpose of this trigger is to ensure only players 21+ can create accounts.
If the player is under 21 years old it will return an error and remove them from the table.
This is very important as we need to keep the law in mind and ensure that only people of age
can be members and be at our casino.
*/
CREATE OR ALTER TRIGGER ko_tr_checkPlayerAge
ON players
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE DATEDIFF(YEAR, date_of_birth, GETDATE()) < 21)
        ROLLBACK TRANSACTION;
        THROW 50001, 'Player cannot be added to players table, as they are under 21 years old.', 1;
END
GO


-- testing (fail, player under 21)
SELECT * FROM players ORDER BY player_id DESC

INSERT INTO players ( first_name, last_name, phone_number, email, date_of_birth, join_date) 
VALUES ('John', 'Doe', '123-456-7890', 'johndoe@example.com', '2010-05-15', GETDATE());
GO

/*
Write the SQL code to create two (2) different complex queries. One of these queries
should use a stored procedure that takes given inputs and returns the expected output.
*/
-- Complex Query 1: see how much a game earned on a specific day
/*
The purpose of this query is to see how much profit a game made on any given day.
It takes in a game_id and date, ensures both are valid and returns the sum of all earnings,
game name, number of players, total play count, and date. This is important as casinos need
to know if their games being played and if they are earning money.
*/
CREATE OR ALTER PROCEDURE ko_sp_GameProfit
	(@game_id INT, @date DATE)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM games WHERE game_id = @game_id)
        THROW 50001, 'Game ID does not exist.', 1;
	ELSE IF (GETDATE() < @date)
		THROW 50001, 'Date is in the future.', 1;

	DECLARE @game_name VARCHAR(255);
    SELECT @game_name = name FROM games WHERE game_id = @game_id;
	DECLARE @total_profit FLOAT;
	DECLARE @numPlays INTEGER;
	DECLARE @numPlayers INTEGER;

	WITH ActiveSessions AS (
        SELECT session_id, player_id
        FROM sessions
		WHERE date = @date),
	GameProfit AS (
		SELECT p.game_id,
			SUM(CASE 
					WHEN p.result = 'win' THEN -p.bet_amount
					WHEN p.result = 'lose' THEN p.bet_amount 
					ELSE 0 
				END) AS gameNetProfit,
			COUNT(p.play_id) as numPlays
		FROM plays p
		INNER JOIN ActiveSessions a ON p.session_id = a.session_id
		WHERE @game_id = p.game_id
		GROUP BY p.game_id
	),
    PlayerCount AS (
        SELECT COUNT(DISTINCT a.player_id) AS numPlayers
        FROM ActiveSessions a
    )
	SELECT @total_profit = COALESCE((SELECT gameNetProfit FROM GameProfit), 0),
		@numPlays = (SELECT numPlays FROM GameProfit),
		@numPlayers = (SELECT numPlayers FROM PlayerCount);
	SELECT 
		@game_name AS GameName,
		COALESCE(@total_profit, 0) AS TotalProfit,
		@date AS Date,
		COALESCE(@numPlays, 0) as NumPlays,
		COALESCE(@numPlayers, 0) as NumPlayers;
END
GO

--pass
EXEC ko_sp_GameProfit @game_id=6, @date='2024-05-11';
GO

--fail
EXEC ko_sp_GameProfit @game_id=7, @date='2024-05-11';
GO

--fail
EXEC ko_sp_GameProfit @game_id=6, @date='2025-05-11';
GO

--Complex Query 2: win percentage of a game
/*
The purpose of this query is to get a summary of players who have committed offenses before.
It's retrieves all players' first incident, last incident, total_offenses, and offense types (concatenated for
multiple offenses). This query can be very useful such as the scenario where we want to see a player's past offense
history to determine if they need to be banned/suspended from the casino.
*/
WITH IncidentDetails AS (
    SELECT 
        il.player_id,
        il.offense_id,
        il.date,
        o.offense_name
    FROM incident_logs il
    JOIN offenses o ON il.offense_id = o.offense_id
),
OffenseCounts AS (
    SELECT 
        player_id,
        COUNT(*) AS TotalOffenses,
        MIN(date) AS FirstIncidentDate,
        MAX(date) AS LastIncidentDate
    FROM IncidentDetails
    GROUP BY player_id
),
OffenseTypeSummary AS (
    SELECT 
        player_id,
        STRING_AGG(offense_name, ', ') AS OffenseTypes
    FROM IncidentDetails
    GROUP BY player_id
)
SELECT 
    p.player_id,
    p.first_name,
    p.last_name,
    oc.TotalOffenses,
    oc.FirstIncidentDate,
    oc.LastIncidentDate,
    ots.OffenseTypes
FROM players p
INNER JOIN OffenseCounts oc ON p.player_id = oc.player_id
LEFT JOIN OffenseTypeSummary ots ON p.player_id = ots.player_id
ORDER BY p.player_id;
GO

--test
INSERT INTO incident_logs (player_id, employee_id, offense_id, description, date)
VALUES(3, 15, 1, 'found stealing 200$ worth of chips', GETDATE())
GO

-- Daniel's queries
/*
 Write the SQL code to create two (2) stored procedures, one for updating data,
 and the second one for deleting a row of data.  Create two (2) associated triggers,
 one to log update operations of your update stored procedure, and the other to log
 delete operations of your delete stored procedure.
 */

 /* 
 Write the SQL code to create one (1) trigger that implements a business logic or a business rule.
*/

/*
Write the SQL code to create two (2) different complex queries. One of these queries
should use a stored procedure that takes given inputs and returns the expected output.
*/

CREATE OR ALTER PROCEDURE dz_UpdatePlayerBalance
    @PlayerID INT,
    @NewBalance DECIMAL(10, 2)
AS
BEGIN
    UPDATE Players
    SET Balance = @NewBalance
    WHERE PlayerID = @PlayerID;
    
    INSERT INTO UpdateLog (PlayerID, NewBalance, UpdateDate)
    VALUES (@PlayerID, @NewBalance, GETDATE());
END;

GO

CREATE PROCEDURE DeletePlayer
    @PlayerID INT
AS
BEGIN
    IF @PlayerID NOT IN (SELECT PlayerID FROM Players)
        THROW 50001, 'Invalid input. That PlayerID does not exist in the Players table.', 1;
	ELSE
    	INSERT INTO DeleteLog (PlayerID, DeleteDate)
    	VALUES (@PlayerID, GETDATE());

    	DELETE FROM Players
    	WHERE PlayerID = @PlayerID;
END;


GO


CREATE TRIGGER trg_AfterUpdatePlayerBalance
ON Players
AFTER UPDATE
AS
BEGIN
    INSERT INTO UpdateLog (PlayerID, NewBalance, UpdateDate)
    SELECT PlayerID, Balance, GETDATE()
    FROM Inserted;
END;

GO

CREATE TRIGGER trg_AfterDeletePlayer
ON Players
AFTER DELETE
AS
BEGIN
    INSERT INTO DeleteLog (PlayerID, DeleteDate)
    SELECT PlayerID, GETDATE()
    FROM Deleted;
END;
GO



CREATE TRIGGER trg_HighStakesMinimumBalance
ON Games
AFTER INSERT
AS
BEGIN
    DECLARE @GameID INT, @MinBalanceRequired DECIMAL(10, 2);
    SELECT @GameID = GameID, @MinBalanceRequired = MinBalanceRequired
    FROM Inserted
    WHERE GameType = 'High Stakes';
    IF EXISTS (SELECT 1 FROM Players WHERE Balance < @MinBalanceRequired)
    BEGIN
        PRINT 'Warning: A player does not meet the minimum balance requirement for high-stakes games.';
    END
END;

GO
SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age > 45 THEN '46+'
    END AS AgeGroup,
    AVG(Spend) AS AvgSpend
FROM Players
JOIN PlayerSpends ON Players.PlayerID = PlayerSpends.PlayerID
GROUP BY 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age > 45 THEN '46+'
    END
ORDER BY AgeGroup;
GO

WITH MonthlyBets AS (
    SELECT 
        GameType,
        DATEPART(MONTH, BetDate) AS BetMonth,
        SUM(BetAmount) AS MonthlyTotalBets
    FROM PlayerBets
    WHERE BetDate >= DATEADD(MONTH, -3, GETDATE())
    GROUP BY GameType, DATEPART(MONTH, BetDate)
),

TopGames AS (
    SELECT 
        GameType,
        SUM(BetAmount) AS TotalBets,
        COUNT(DISTINCT PlayerID) AS UniquePlayers
    FROM PlayerBets
    GROUP BY GameType
    HAVING SUM(BetAmount) > 10000
    ORDER BY TotalBets DESC
)

SELECT 
    TG.GameType,
    TG.TotalBets,
    TG.UniquePlayers,
    MB.BetMonth,
    MB.MonthlyTotalBets
FROM TopGames TG
JOIN MonthlyBets MB ON TG.GameType = MB.GameType
ORDER BY TG.TotalBets DESC, MB.BetMonth ASC;