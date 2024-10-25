CREATE DATABASE HighRollerDB;
GO
USE HighRollerDB;

-- Create tables
CREATE TABLE players
(
    player_id INTEGER NOT NULL IDENTITY(1,1),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    join_date DATE NOT NULL,
    PRIMARY KEY (player_id)
);

CREATE TABLE employees
(
    employee_id INTEGER NOT NULL IDENTITY(1,1),
    table_id INTEGER NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    PRIMARY KEY (employee_id)
);

CREATE TABLE offenses
(
    offense_id INTEGER NOT NULL IDENTITY(1,1),
    offense_name VARCHAR(50) NOT NULL,
    description VARCHAR(200) NOT NULL,
    PRIMARY KEY (offense_id)
);

CREATE TABLE incident_logs
(
    incident_id INTEGER NOT NULL IDENTITY(1,1),
    player_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    offense_id INTEGER NOT NULL,
    description VARCHAR(200) NOT NULL,
    date DATE NOT NULL,
    PRIMARY KEY (incident_id)
);

CREATE TABLE funds
(
    fund_id INTEGER NOT NULL IDENTITY(1,1),
    player_id INTEGER NOT NULL,
    balance MONEY NOT NULL,
    PRIMARY KEY (fund_id)
);

CREATE TABLE transactions
(
    transaction_id INTEGER NOT NULL IDENTITY(1,1),
    fund_id INTEGER NOT NULL,
    amount MONEY NOT NULL,
    PRIMARY KEY (transaction_id)
);


CREATE TABLE sessions
(
    session_id INTEGER NOT NULL IDENTITY(1,1),
    player_id INTEGER NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    total_plays INTEGER NOT NULL,
    PRIMARY KEY (session_id)
);

CREATE TABLE games
(
    game_id INTEGER NOT NULL IDENTITY(1,1),
    name VARCHAR(20) NOT NULL,
    description VARCHAR(200) NOT NULL,
    min_bet MONEY NOT NULL,
    max_bet MONEY NOT NULL,
    PRIMARY KEY (game_id)
);

CREATE TABLE plays
(
    play_id INTEGER NOT NULL IDENTITY(1,1),
    session_id INTEGER NOT NULL,
    game_id INTEGER NOT NULL,
    bet_amount MONEY NOT NULL,
    result VARCHAR(4) NOT NULL,
    PRIMARY KEY (play_id)
);

CREATE TABLE jackpots
(
    jackpot_id INTEGER NOT NULL IDENTITY(1,1),
    player_id INTEGER,
    amount MONEY NOT NULL,
    PRIMARY KEY (jackpot_id)
);

CREATE TABLE machines
(
    machine_id INTEGER NOT NULL IDENTITY(1,1),
    game_id INTEGER NOT NULL,
    max_payout MONEY NOT NULL,
    status VARCHAR(20),
    PRIMARY KEY (machine_id)
);

CREATE TABLE tables
(
    table_id INTEGER NOT NULL IDENTITY(1,1),
    game_id INTEGER NOT NULL,
    capacity INTEGER NOT NULL,
    PRIMARY KEY (table_id)
);

CREATE TABLE items
(
    item_id INTEGER NOT NULL IDENTITY(1,1),
    item_name VARCHAR(50) NOT NULL,
    quantity_in_stock INTEGER NOT NULL,
    PRIMARY KEY (item_id)
);

CREATE TABLE table_items
(
    table_item_id INTEGER NOT NULL IDENTITY(1,1),
    table_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    PRIMARY KEY (table_item_id)
);

--For windows: Add data
BULK INSERT employees
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\employees.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
)

BULK INSERT funds
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\funds.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  
	ROWTERMINATOR = '\n',   
	TABLOCK
)

BULK INSERT games
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\games.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
)

--incident logs
BULK INSERT incident_logs
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\incidents.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  
	ROWTERMINATOR = '\n',   
	TABLOCK
)

BULK INSERT items
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\items.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  
	ROWTERMINATOR = '\n',   
	TABLOCK
)

--jackpots
BULK INSERT jackpots
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\jackpots.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  
	ROWTERMINATOR = '\n',   
	TABLOCK
)

--machines
BULK INSERT machines
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\machines.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  
	ROWTERMINATOR = '\n',   
	TABLOCK
)


BULK INSERT offenses
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\offenses.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
)

BULK INSERT players
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\players.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
)

--plays
BULK INSERT plays
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\plays.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  
	ROWTERMINATOR = '\n',   
	TABLOCK
)

--sessions
BULK INSERT sessions
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\sessions.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  
	ROWTERMINATOR = '\n',   
	TABLOCK
)

--tables_items
BULK INSERT table_items
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\table_items.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  
	ROWTERMINATOR = '\n',   
	TABLOCK
)

--tables
BULK INSERT tables
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\tables.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  
	ROWTERMINATOR = '\n',   
	TABLOCK
)

BULK INSERT transactions
FROM 'C:\Users\mrpi3\OneDrive\Documents\UW Files\UW Fall 2024\INFO 430\HighRollerDB\data\transactions.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  
	ROWTERMINATOR = '\n',   
	TABLOCK
)

-- Add foreign keys
ALTER TABLE employees
    ADD CONSTRAINT fk_employee_table_id FOREIGN KEY (table_id) REFERENCES tables (table_id)

ALTER TABLE incident_logs
    ADD CONSTRAINT fk_incident_player_id FOREIGN KEY (player_id) REFERENCES players (player_id),
    CONSTRAINT fk_incident_employee_id FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    CONSTRAINT fk_incident_offense_id FOREIGN KEY (offense_id) REFERENCES offenses (offense_id);

ALTER TABLE funds
    ADD CONSTRAINT fk_fund_player_id FOREIGN KEY (player_id) REFERENCES players (player_id);

ALTER TABLE transactions
    ADD CONSTRAINT fk_transaction_fund_id FOREIGN KEY (fund_id) REFERENCES funds (fund_id);

ALTER TABLE sessions
    ADD CONSTRAINT fk_session_player_id FOREIGN KEY (player_id) REFERENCES players (player_id);

ALTER TABLE plays
    ADD CONSTRAINT fk_play_session_id FOREIGN KEY (session_id) REFERENCES sessions (session_id),
    CONSTRAINT fk_play_game_id FOREIGN KEY (game_id) REFERENCES games (game_id);

ALTER TABLE jackpots
    ADD CONSTRAINT fk_jackpot_player_id FOREIGN KEY (player_id) REFERENCES players (player_id);

ALTER TABLE machines
    ADD CONSTRAINT fk_machine_game_id FOREIGN KEY (game_id) REFERENCES games (game_id);

ALTER TABLE tables
    ADD CONSTRAINT fk_table_game_id FOREIGN KEY (game_id) REFERENCES games (game_id);

ALTER TABLE table_items
    ADD CONSTRAINT fk_tableitem_table_id FOREIGN KEY (table_id) REFERENCES tables (table_id),
    CONSTRAINT fk_tableitem_item_id FOREIGN KEY (item_id) REFERENCES items (item_id);


--For Mac
-- BULK INSERT employees
-- FROM '/employees.csv'
-- WITH
-- (
--     FIRSTROW = 2,
--     FIELDTERMINATOR = ',',  --CSV field delimiter
--     ROWTERMINATOR = '\n',   --Use to shift the control to next row
--     TABLOCK
-- )

-- BULK INSERT offense
-- FROM '/offense.csv'
-- WITH
-- (
--     FIRSTROW = 2,
--     FIELDTERMINATOR = ',',  --CSV field delimiter
--     ROWTERMINATOR = '\n',   --Use to shift the control to next row
--     TABLOCK
-- )
-- ALTER TABLE games
-- ALTER COLUMN max_bet SMALLMONEY;




-- BULK INSERT games
-- FROM '/games.csv'
-- WITH
-- (
--     FIRSTROW = 2,
--     FIELDTERMINATOR = ',',  --CSV field delimiter
--     ROWTERMINATOR = '\n',   --Use to shift the control to next row
--     TABLOCK
-- )
