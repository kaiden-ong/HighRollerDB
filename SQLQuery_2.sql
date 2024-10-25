--Calculate total winnings in a session
USE HighRollerDB
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
    RETURN IFNULL(@TotalWinnings, 0);
END;
GO
O
CREATE PROCEDURE updateFunds
(@transaction_amount DECIMAL(10,2))
AS
BEGIN
--Look up product using product name
DECLARE @ProdID int
SET @ProdID = (SELECT ProductID FROM tblPRODUCT WHERE ProductName =
@ProdName)
--look up old price
DEClARE @oldPrice numeric(5,2)
SET @oldPrice = (SELECT Price FROM tblPRODUCT WHERE ProductName = @ProdName)
--Error handling
IF @ProdID IS NULL
THROW 50061, '@ProdTypeID cannot be NULL; statement is
terminating', 1;
--Update product price if everything is fine
Else
BEGIN
UPDATE tblPRODUCT
SET Price = @NewPrice
WHERE ProductID = @ProdID
--provide feedback to the user
Print (CONCAT('Price for Product ', @ProdName, ' updated from ',
@oldPrice,
' to ', @NewPrice));
END

