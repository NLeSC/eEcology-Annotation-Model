%% connectEecologyDB - get database connection to eEcology database
%
% -----------------------------------------------------------------------
% SYNTAX
% connection = connectEecologyDB(username, password)
%
% INPUT
% username, password- the string credentials for logging to the eEcology DB
% dbhost - Hostname of database
%
% OUPTPUT
% connection - Database connection object
%
% EXAMPLE
% connection = getDataFromEecologyDB(<your-user-name>, <your-password>)
%
% SEE ALSO
% DBAcc_Texel/FEBO.m scripts from W. Bouten (legacy)
%
% REFERENCES

function connection = connectEecologyDB(dbhost, username, password)

% TODO make dbname, dbhost optional function arguments
dbname = 'eecology?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory';
% dbhost = 'db.e-ecology.sara.nl';

% Find jdbc driver
pg_settings();
% Connect
connection = pg_connectdb(dbname, 'host', dbhost, 'user', username, 'pass', password);
