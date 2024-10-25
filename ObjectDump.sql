USE HighRollerDB
GO
--Kaiden's DB Objects

--1) Stored Procedure
--Adding a new player
CREATE OR ALTER PROCEDURE InsertTable
	(@game_name VARCHAR(20),
	@capacity INTEGER)
AS
BEGIN
	DECLARE @game_id INTEGER
	SET @game_id = (SELECT game_id
					FROM games g
					WHERE g.name = @game_name)

	IF @game_id IS NULL
		THROW 50001, 'GAME ID is null for the info entered.
		Please try different inputs', 1;
	ELSE
		INSERT INTO tables (game_id, capacity)
		VALUES (@game_id, @capacity)
		print(CONCAT(@game_name, ' was inserted successfuly into the database'))
END
GO

SELECT TOP 1 * FROM tables
ORDER BY table_id DESC

SELECT * FROM games

--Guaranteed to fail
EXEC InsertTable 'fail', 8

--Guaranteed to pass
DECLARE @g_name VARCHAR(20) = 'Craps';
DECLARE @g_cap INT = '8';

EXEC InsertTable @g_name, @g_cap

SELECT TOP 1 * FROM tables
ORDER BY table_id DESC
GO

--2) Nested stored procedure
--get offense id
CREATE OR ALTER PROCEDURE getOffense
	(@offense_name VARCHAR(50),
		@offense_id INTEGER OUTPUT)
AS
BEGIN
	SET @offense_id = (SELECT o.offense_id
							FROM offenses o
							WHERE o.offense_name = @offense_name)
END
GO

--get employee id
CREATE OR ALTER PROCEDURE getEmployee
	(@employee_fname VARCHAR(50),
	@employee_lname VARCHAR(50),
	@employee_job VARCHAR(50),
	@employee_table INTEGER,
		@employee_id INTEGER OUTPUT)
AS
BEGIN
	SET @employee_id = (SELECT e.employee_id
							FROM employees e
							WHERE e.first_name = @employee_fname
								AND e.last_name = @employee_lname
								AND e.job_title = @employee_job
								AND e.table_id = @employee_table)
END
GO

--get player id
CREATE OR ALTER PROCEDURE getPlayer
	(@player_fname VARCHAR(50),
	@player_lname VARCHAR(50),
	@player_phone VARCHAR(50),
	@player_email VARCHAR(50),
		@player_id INTEGER OUTPUT)
AS
BEGIN
	SET @player_id = (SELECT p.player_id
							FROM players p
							WHERE p.first_name = @player_fname
								AND p.last_name = @player_lname
								AND p.phone_number = @player_phone
								AND p.email = @player_email)
END
GO

CREATE OR ALTER PROCEDURE InsertIncidentLog
	(@player_fname VARCHAR(50),
	@player_lname VARCHAR(50),
	@player_phone VARCHAR(50),
	@player_email VARCHAR(50),
	@employee_fname VARCHAR(50),
	@employee_lname VARCHAR(50),
	@employee_job VARCHAR(50),
	@employee_table INTEGER,
	@offense_name VARCHAR(50),
	@desc VARCHAR(200),
	@date DATE)
AS
BEGIN
	DECLARE @p_id INTEGER
	EXEC getPlayer @player_fname, @player_lname, @player_phone, @player_email,
		@player_id = @p_id OUTPUT

	DECLARE @e_id INTEGER
	EXEC getEmployee @employee_fname, @employee_lname, @employee_job, @employee_table,
		@employee_id = @e_id OUTPUT

	DECLARE @o_id INTEGER
	EXEC getOffense @offense_name,
		@offense_id = @o_id OUTPUT

	IF @p_id IS NULL
		THROW 50001, 'PLAYER ID is null for the info entered.
		Please try different inputs', 1;
	ELSE IF @e_id IS NULL
		THROW 50001, 'EMPLOYEE ID is null for the info entered.
		Please try different inputs', 1;
	ELSE IF @o_id IS NULL
		THROW 50001, 'OFFENSE ID is null for the info entered.
		Please try different inputs', 1;
	ELSE
		INSERT INTO incident_logs(player_id, employee_id, offense_id,
			description, date)
		VALUES(@p_id, @e_id, @o_id, @desc, @date)
		print(CONCAT('Incident with player ', @p_id, ' and employee ', @e_id, ' was inserted successfuly into the database'))
END
GO

SELECT TOP 1 * FROM incident_logs
ORDER BY incident_id DESC

SELECT * FROM offenses

--Guaranteed to fail
EXEC InsertIncidentLog 'player', 'Mark', '345-234-5423', 'email@email.com', 'employee', 'jack', 'Janitor', 2, 'theft',
	'stole some stuff', '2024-02-14'

--Guaranteed to pass
DECLARE @player_fname VARCHAR(50) = 'Scotti'
DECLARE @player_lname VARCHAR(50) = 'Jacomb'
DECLARE @player_phone VARCHAR(50) = '850-418-9510'
DECLARE @player_email VARCHAR(50) = 'sjacomb2@sphinn.com'
DECLARE @employee_fname VARCHAR(50) = 'Harv'
DECLARE @employee_lname VARCHAR(50) = 'Seaborne'
DECLARE @employee_job VARCHAR(50) = 'Cashier'
DECLARE @employee_table INTEGER = 7
DECLARE @offense_name VARCHAR(50) = 'Cheating'
DECLARE @desc VARCHAR(200) = 'Found guilty of cheating at poker game at table 7'
DECLARE @date DATE = '2024-10-25'

EXEC InsertIncidentLog @player_fname, @player_lname, @player_phone, @player_email, @employee_fname,
	@employee_lname, @employee_job, @employee_table, @offense_name, @desc, @date

SELECT TOP 1 * FROM tables
ORDER BY table_id DESC
GO


--3) Check constraint
ALTER TABLE plays
ADD CONSTRAINT check_play_result CHECK (result IN ('win', 'lose'));

--4) Computed Column: Calculate total winnings in a session
ALTER TABLE sessions
ADD total_winnings MONEY NULL;
GO

CREATE FUNCTION dbo.calculateTotalWinnings(@SessionID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @TotalWinnings MONEY;
    SELECT 
        @TotalWinnings = SUM(CASE 
                                WHEN p.result = 'win' THEN p.bet_amount 
                                WHEN p.result = 'lose' THEN -p.bet_amount 
                                ELSE 0 
                            END)
    FROM 
        plays p
    WHERE 
        p.session_id = @SessionID;
    RETURN @TotalWinnings;
END;
GO

UPDATE sessions
SET total_winnings = dbo.calculateTotalWinnings(session_id);

--Daniel's DB Objects

--1) Stored Procedure

--2) Nested stored procedure

--3) Check constraint

--4) Computed Column: Calculate total winnings in a session