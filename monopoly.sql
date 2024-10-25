--
-- This SQL script builds a monopoly database, deleting any pre-existing version.
--
-- @author kvlinden
-- @version Summer, 2015
--
-- @author Zhonglin-Niu
-- @version Oct. 2024
--

-- Drop previous versions of the tables if they they exist, in reverse order of foreign keys.
DROP TABLE IF EXISTS Game;
DROP TABLE IF EXISTS Player;
DROP TABLE IF EXISTS PlayerPosition;
DROP TABLE IF EXISTS Property;
DROP TABLE IF EXISTS PropertyAsset;
DROP TABLE IF EXISTS PlayerGame;

-- Create the schema.
CREATE TABLE Game (
    ID integer PRIMARY KEY,
    time timestamp,
    is_completed boolean DEFAULT false  -- Indicates if the game has finished
);

CREATE TABLE Player (
    ID integer PRIMARY KEY, 
    emailAddress varchar(50) NOT NULL,  -- Player's unique email for identification
    name varchar(50)                    -- Player's display name
);

CREATE TABLE PlayerPosition (
    gameID integer,
    playerID integer,
    board_position integer NOT NULL,    -- Position on board (0-39), where 0 is GO
    FOREIGN KEY (gameID, playerID) REFERENCES PlayerGame(gameID, playerID),
    PRIMARY KEY (gameID, playerID)
);

CREATE TABLE Property (
    ID integer PRIMARY KEY,
    name varchar(50) NOT NULL,          -- Name of the property
    price integer NOT NULL,             -- Purchase price
    house_price integer,                -- Cost to build a house
    hotel_price integer,                -- Cost to build a hotel
    rent_base integer,                  -- Basic rent without houses
    rent_house integer,                 -- Rent with one house
    rent_hotel integer                  -- Rent with a hotel
);

CREATE TABLE PropertyAsset (
    gameID integer,
    playerID integer,
    propertyID integer REFERENCES Property(ID),
    num_houses integer DEFAULT 0,       -- Number of houses
    has_hotel boolean DEFAULT false,    -- True if property has a hotel
    FOREIGN KEY (gameID, playerID) REFERENCES PlayerGame(gameID, playerID),
    PRIMARY KEY (gameID, propertyID)
);

CREATE TABLE PlayerGame (
    gameID integer REFERENCES Game(ID), 
    playerID integer REFERENCES Player(ID),
    score integer DEFAULT 0,            -- Current score/net worth
    cash integer DEFAULT 10000,         -- Current cash amount
    PRIMARY KEY (gameID, playerID)
);

-- Grant permissions
GRANT SELECT ON Game TO PUBLIC;
GRANT SELECT ON Player TO PUBLIC;
GRANT SELECT ON PlayerPosition TO PUBLIC;
GRANT SELECT ON Property TO PUBLIC;
GRANT SELECT ON PropertyAsset TO PUBLIC;
GRANT SELECT ON PlayerGame TO PUBLIC;

-- Sample game records
INSERT INTO Game VALUES (1, '2024-06-27 08:00:00', false);  -- Ongoing game
INSERT INTO Game VALUES (2, '2024-06-28 13:20:00', true);   -- Completed game
INSERT INTO Game VALUES (3, '2024-06-29 15:45:00', false);  -- Another ongoing game
INSERT INTO Game VALUES (4, '2024-06-30 19:30:00', true);   -- Another completed game

-- Sample player records
INSERT INTO Player(ID, emailAddress) VALUES (1, 'me@calvin.edu');
INSERT INTO Player VALUES (2, 'king@gmail.edu', 'The King');
INSERT INTO Player VALUES (3, 'dog@gmail.edu', 'Dogbreath');
INSERT INTO Player VALUES (4, 'queen@gmail.edu', 'The Queen');
INSERT INTO Player VALUES (5, 'lniu@gmail.com', 'Loya');

-- Sample property records (following actual Monopoly board)
INSERT INTO Property VALUES (1, 'Mediterranean Avenue', 60, 50, 50, 2, 10, 250);
INSERT INTO Property VALUES (2, 'Baltic Avenue', 60, 50, 50, 4, 20, 450);
INSERT INTO Property VALUES (3, 'Reading Railroad', 200, NULL, NULL, 25, NULL, NULL);
INSERT INTO Property VALUES (4, 'Oriental Avenue', 100, 50, 50, 6, 30, 550);
INSERT INTO Property VALUES (5, 'Vermont Avenue', 100, 50, 50, 6, 30, 550);
INSERT INTO Property VALUES (6, 'Connecticut Avenue', 120, 50, 50, 8, 40, 600);
INSERT INTO Property VALUES (7, 'Boardwalk', 400, 200, 200, 50, 200, 2000);

-- Sample player positions
INSERT INTO PlayerPosition VALUES (1, 1, 0);   -- Player 1 on GO
INSERT INTO PlayerPosition VALUES (1, 2, 3);   -- Player 2 on Oriental Avenue
INSERT INTO PlayerPosition VALUES (1, 3, 10);  -- Player 3 in Jail
INSERT INTO PlayerPosition VALUES (2, 1, 5);   -- Player 1 on Reading Railroad
INSERT INTO PlayerPosition VALUES (2, 2, 15);  -- Player 2 on Vermont Avenue
INSERT INTO PlayerPosition VALUES (2, 4, 20);  -- Player 4 on Free Parking

-- Sample property assets
INSERT INTO PropertyAsset VALUES (1, 1, 1, 2, false);  -- Player 1 owns Mediterranean with 2 houses
INSERT INTO PropertyAsset VALUES (1, 2, 2, 0, true);   -- Player 2 owns Baltic with hotel
INSERT INTO PropertyAsset VALUES (1, 3, 3, 0, false);  -- Player 3 owns Reading Railroad
INSERT INTO PropertyAsset VALUES (2, 1, 4, 3, false);  -- Player 1 owns Oriental with 3 houses
INSERT INTO PropertyAsset VALUES (2, 2, 5, 4, false);  -- Player 2 owns Vermont with 4 houses
INSERT INTO PropertyAsset VALUES (2, 4, 6, 0, true);   -- Player 4 owns Connecticut with hotel

-- Sample player game records with varying cash amounts and scores
INSERT INTO PlayerGame VALUES (1, 1, 1500, 5000);    -- Game 1, Player 1
INSERT INTO PlayerGame VALUES (1, 2, 800, 3000);     -- Game 1, Player 2
INSERT INTO PlayerGame VALUES (1, 3, 2350, 4200);    -- Game 1, Player 3
INSERT INTO PlayerGame VALUES (2, 1, 3000, 6000);    -- Game 2, Player 1
INSERT INTO PlayerGame VALUES (2, 2, 2500, 4800);    -- Game 2, Player 2
INSERT INTO PlayerGame VALUES (2, 4, 1800, 3500);    -- Game 2, Player 4
INSERT INTO PlayerGame VALUES (3, 3, 900, 2000);     -- Game 3, Player 3
INSERT INTO PlayerGame VALUES (3, 4, 1200, 2500);    -- Game 3, Player 4
INSERT INTO PlayerGame VALUES (3, 5, 1500, 3000);    -- Game 3, Player 5