--Kaiden's DB Objects
ALTER TABLE sessions
ADD total_winnings SMALLMONEY NULL;

--Calculate total winnings in a session
CREATE FUNCTION dbo.calculateTotalWinnings(@SessionID INT)
RETURNS SMALLMONEY
AS
BEGIN
    DECLARE @TotalWinnings SMALLMONEY;
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
    RETURN IFNULL(@TotalWinnings, 0);
END;

UPDATE sessions
SET total_winnings = dbo.calculateTotalWinnings(session_id);


-- Daniel's DB Objects