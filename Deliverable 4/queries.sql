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
-- prevent players under 21 from joining
/*
The purpose of this trigger is to ensure only players 21+ can create accounts.
If the player is under 21 years old it will return an error and remove them from the table.
This is very important as we need to keep the law in mind and ensure that only people of age
can gamble at our casino.
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


-- testing
SELECT * FROM players ORDER BY player_id DESC

INSERT INTO players ( first_name, last_name, phone_number, email, date_of_birth, join_date) 
VALUES ('John', 'Doe', '123-456-7890', 'johndoe@example.com', '2010-05-15', GETDATE());
GO
/*
Write the SQL code to create two (2) different complex queries. One of these queries
should use a stored procedure that takes given inputs and returns the expected output.
*/
-- see how much a game earned on a specific day
/*
The purpose of this query is to see how much profit a game made on any given day.
It takes in a game_id and date, ensures both are valid and returns the sum of all earning,
positive and negative. This is important as casinos need to know if their games are earning
money and this is a great way to check.
*/
CREATE OR ALTER PROCEDURE ko_sp_GameProfit
	(@game_id INT, @date DATE)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM games WHERE game_id = @game_id)
        THROW 50001, 'Game ID does not exist.', 1;
	ELSE IF (GETDATE() < @date)
		THROW 50001, 'Date is in the future.', 1;

	WITH ActiveSessions AS (
        SELECT session_id
        FROM sessions
		WHERE date = @date)
	SELECT p.game_id,
        SUM(CASE 
                WHEN p.result = 'win' THEN -p.bet_amount
				WHEN p.result = 'lose' THEN p.bet_amount 
                ELSE 0 
            END) AS gameNetProfit
	FROM plays p
	INNER JOIN ActiveSessions a ON p.session_id = a.session_id
	WHERE @game_id = p.game_id
	GROUP BY p.game_id
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