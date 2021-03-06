USE [MDT]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[InsertComputerName]
@MacAddress CHAR(17)

AS

DECLARE @Cnt INT,
        @Prefix VARCHAR(50),
        @Sequence INT,
        @NewName VARCHAR(50)

SET NOCOUNT ON

/* See if there is an existing record for this machine */

SELECT @Cnt=COUNT(*) FROM ComputerIdentity
WHERE MacAddress = @MacAddress

/* No record?  Add one.  */

IF @Cnt = 0
BEGIN

    /* Create a new machine name */

	BEGIN TRAN

    SELECT @Prefix=Prefix, @Sequence=Sequence FROM MachineNameSequence
    SET @Sequence = @Sequence + 1
    UPDATE MachineNameSequence SET Sequence = @Sequence
    SET @NewName = @Prefix + Right('00000'+LTrim(Str(@Sequence)),5)

    /* Insert the new record */

	INSERT INTO ComputerIdentity (MacAddress, Description) 
	VALUES (@MacAddress, 'New York Site - ' + @NewName)
	INSERT INTO Settings (Type, ID, OSDComputerName, OSInstall, SkipComputerName) 
	VALUES ('C',@@IDENTITY, @NewName, 'Y', 'YES')

    COMMIT TRAN

END

/*  Return the record as the result set */

SELECT * FROM ComputerIdentity
WHERE MacAddress = @MacAddress


GO