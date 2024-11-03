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

-- deleting a row from the players table
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

-- trigger logging update operations
CREATE TABLE ko_jackpot_log(jackpot_id INT,
							player_id VARCHAR(60),
							amount INT,
							log_time DATETIME,
							log_action VARCHAR(60))
GO

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

-- trigger logging delete operations
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

 /* 
 Write the SQL code to create one (1) trigger that implements a business logic or a business rule.
*/


/*
Write the SQL code to create two (2) different complex queries. One of these queries
should use a stored procedure that takes given inputs and returns the expected output.
*/






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


--Daniel Zhang Queries 

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