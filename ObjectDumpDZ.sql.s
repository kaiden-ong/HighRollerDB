--Daniel Zhang DB Objects

--1) Check constraint
ALTER TABLE funds
ADD CONSTRAINT CHK_Funds_Balance_Positive
CHECK (balance >= 0);
GO

--2) Stored Procedure
CREATE PROCEDURE InsertFund
    @player_email VARCHAR(50),  -- Lookup value
    @initial_balance MONEY
AS
BEGIN
    DECLARE @player_id INT;
    
    -- Lookup for player_id based on email
    SELECT @player_id = player_id FROM players WHERE email = @player_email;
    
    -- Insert new fund record if player_id is found
    IF @player_id IS NOT NULL
    BEGIN
        INSERT INTO funds (player_id, balance)
        VALUES (@player_id, @initial_balance);
    END
    ELSE
    BEGIN
        PRINT 'Player not found.';
    END
END;

-- Assuming "esent0@umich.edu" exists in the players table
EXEC InsertFund @player_email = 'esent0@umich.edu', @initial_balance = 100.00;

-- Assuming "nonexistent_player@example.com" does not exist in the players table
EXEC InsertFund @player_email = 'nonexistent_player@example.com', @initial_balance = 50.00;

GO

--3) nested stored procedure


CREATE PROCEDURE GetPlayerIDByName
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @player_id INT OUTPUT
AS
BEGIN
    SELECT @player_id = player_id
    FROM players
    WHERE first_name = @first_name AND last_name = @last_name;
END;

GO

CREATE OR ALTER PROCEDURE InsertIncidentLog
    @employee_id INT,
    @player_first_name VARCHAR(50),
    @player_last_name VARCHAR(50),
    @offense_name VARCHAR(50),
    @description VARCHAR(200),
    @date DATE,
    @incident_id INT OUTPUT       -- Output parameter to return new incident_id
AS
BEGIN
    DECLARE @player_id INT, @offense_id INT;

    BEGIN TRY
        EXEC GetPlayerIDByName @player_first_name, @player_last_name, @player_id OUTPUT;

        SELECT @offense_id = offense_id
        FROM dbo.offense
        WHERE offense_name = @offense_name;
        --checks for null values
        IF @player_id IS NULL
            THROW 50001, 'PLAYER ID is null for the info entered. Please try different inputs.', 1;

        ELSE IF @employee_id IS NULL
            THROW 50002, 'EMPLOYEE ID is null for the info entered. Please try different inputs.', 1;

        ELSE IF @offense_id IS NULL
            THROW 50003, 'OFFENSE ID is null for the info entered. Please try different inputs.', 1;

        ELSE
        BEGIN
            INSERT INTO incident_logs (player_id, employee_id, offense_id, description, date)
            VALUES (@player_id, @employee_id, @offense_id, @description, @date);

            SET @incident_id = SCOPE_IDENTITY();

            PRINT CONCAT('Incident with player ', @player_id, ' and employee ', @employee_id, ' was successfully inserted into the database.');
        END;
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred: ' + ERROR_MESSAGE();
    END CATCH;
END;

GO

--Gaurenteed pass with real player
DECLARE @incident_id INT;
EXEC InsertIncidentLog 
    @employee_id = 1, 
    @player_first_name = 'Erie', 
    @player_last_name = 'Sent', 
    @offense_name = 'Cheating', 
    @description = 'Caught in the act.', 
    @date = '2024-10-25', 
    @incident_id = @incident_id OUTPUT;
PRINT 'New incident ID: ' + CAST(@incident_id AS NVARCHAR(10));


--Garenteed fail with fake player 
DECLARE @incident_id INT;
EXEC InsertIncidentLog 
    @employee_id = 1, 
    @player_first_name = 'John', 
    @player_last_name = 'Plant', 
    @offense_name = 'Cheating', 
    @description = 'Caught in the act.', 
    @date = '2024-10-25', 
    @incident_id = @incident_id OUTPUT;
PRINT 'New incident ID: ' + CAST(@incident_id AS NVARCHAR(10));

--4) calculated column 

ALTER TABLE sessions
ADD total_penalties MONEY NULL;
GO


CREATE FUNCTION dbo.calculateTotalPenalties(@SessionID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @TotalPenalties MONEY;
    SELECT 
        @TotalPenalties = SUM(p.penalty_amount)
    FROM 
        penalties p
    WHERE 
        p.session_id = @SessionID;
    RETURN @TotalPenalties;
END;
GO
