--Calculate total winnings in a session
USE HighRollerDB
GO

ALTER TABLE sessions
ADD total_winnings SMALLMONEY NULL;
GO

CREATE FUNCTION dbo.calculateTotalWinnings(@SessionID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalWinnings DECIMAL(10,2);
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
    RETURN (@TotalWinnings);
END;
GO

UPDATE sessions
SET total_winnings = dbo.calculateTotalWinnings(session_id);