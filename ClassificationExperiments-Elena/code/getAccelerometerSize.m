%% getAccelerometerSize - Number of accelerometer measurements. Fetched from eEcology database.
%
% -----------------------------------------------------------------------
% SYNTAX
% num_meas = getAccelerometerSize(connection, ...
%                                 device, starttime, stoptime,...
%                                 limited)
%
% INPUT
% connection - Database connection object
% device - device ID for which the data are to be  retrieved
% starttime and stoptime- define the time strip of interest.
%                         Strings of format 'yyy-mm-dd hh:mm:ss'
% limited - Use limited views or not. Defaults to false, not using limited views.
%
% OUPTPUT
% num_meas - Number of accelerometer measurements
%
% EXAMPLE
% num_meas = getAccelerometerSize(connection,...
%                                754, '2013-06-08 06:20:00', ...
%                                '2013-06-08 07:20:00', true)
%
% SEE ALSO
%
% REFERENCES

function num_meas = getAccelerometerSize(connection, ...
                                         device, starttime, stoptime,...
                                         limited)

sql_query_tpl = [
    'SELECT \n',...
    'max(index)+1 \n',...
    'FROM gps.uva_acceleration101\n',...
    'WHERE device_info_serial = %d \n',...
    'AND date_time BETWEEN ''%s'' AND ''%s'' \n'
];

if limited
    sql_query_tpl = [
        'SELECT \n',...
        'max(index)+1 \n',...
        'FROM gps.uva_acceleration_limited\n',...
        'WHERE device_info_serial = %d \n',...
        'AND date_time BETWEEN ''%s'' AND ''%s'' \n'
    ];
end

%% Generate/load query
sql_query = sprintf(sql_query_tpl, device, starttime, stoptime, device, starttime, stoptime);

% Run query
data = pg_fetch_struct(connection, sql_query);


