USE HighRollerDB

--Kaiden's DB Objects

--1) Stored Procedure

--2) Nested stored procedure

--3) Check constraint
ALTER TABLE plays
ADD CONSTRAINT check_play_result CHECK (result IN ('win', 'lose'));

--4) Computed Column: Calculate total winnings in a session
ALTER TABLE sessions
ADD total_winnings SMALLMONEY NULL;
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