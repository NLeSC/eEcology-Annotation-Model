function [data]=GetDataFromDB(username, password, device)
%% GetDataFromDB - get the GPS, accellerometer and speed data from the eecology DB for given device
% author: Elena Ranguelova
% date: 15-08-2013
% 
% SYNTAX
% [data]=GetDataFromDB(username, password, device)
%
% INPUT
% username, password- the credentials (strings) to access the eecology DB
% devices- device IDs for which the data will be retrieved
%
% OUPTPUT
% data- structure containing the GPS, accellerometer and speed data 
%
% EXAMPLE
%
% SEE ALSO
%
% REFERENCES




%% Parameters
IDevice= num2str(device)

%% Connect to the eecology DB given the credentials using jdbc driver
 
conn = database('eecology', username, password,'org.postgresql.Driver', 'jdbc:postgresql://db.e-ecology.sara.nl:5432/eecology?sslfactory=org.postgresql.ssl.NonValidatingFactory&ssl=true')

%% Set the DB preferences
% set database pref. this determines how the results are returned. 
% 'structure' means you can reference the fields by the same names as the
% database tables use. ( see doc setdbprefs ) 
setdbprefs('DataReturnFormat','structure');

%% Query
sql1 = strcat('select s.device_info_serial, s.date_time, a.date_time, ', ...
               ' date_part(''year''::text, s.date_time) AS year, ',...
               ' date_part(''month''::text, s.date_time) AS month, ',...
               ' date_part(''day''::text, s.date_time) AS day, ',...
               ' date_part(''hour''::text, s.date_time) AS hour, ',...
               ' date_part(''minute''::text, s.date_time) AS minute, ',...
               ' date_part(''second''::text, s.date_time) AS second, ',...
               ' s.speed, s.longitude, s.latitude, s.altitude, t.speed as tspeed, ',...
               ' a.index,(a.x_acceleration-d.x_o)/d.x_s as x_cal, ',...
               ' (a.y_acceleration-d.y_o)/d.y_s as y_cal, ',...
               ' (a.z_acceleration-d.z_o)/d.z_s as z_cal ',...
               ' FROM gps.uva_tracking_speed s ',...
               ' LEFT join gps.uva_acceleration101 a ',...  
               ' ON (s.device_info_serial = a.device_info_serial AND s.date_time = a.date_time) ',...
               ' LEFT join gps.uva_device d ',...
               ' ON a.device_info_serial = d.device_info_serial ',...
               ' LEFT join gps.get_uvagps_track_speed (',IDevice, ',' ,start, ',' ,stop, ' ) t ',...
               ' ON s.device_info_serial = t.device_info_serial and s.date_time = t.date_time ',...
               ' where s.device_info_serial = ',IDevice , ' and ',...
               ' s.date_time >', start, ' and s.date_time < ' ,stop, ' and s.latitude is not null and s.userflag <> 1 ',...
               ' order by  s.date_time, a.index');
           
    %% Execute the query  
    % get a 'database cursor' 
    % this sends the sql command to the database and returns a 
    % 'cursor' that can be used to retreive the data in the table. 
    curs1 = exec(conn,sql1);

    % this fetch command actually transfers the data from database table to matlab
    curs1 = fetch(curs1);

    %% get the data from the cursor
    % because previously setdbprefs is set to 'structure' devices
    % is a struct with array fields that have the same name as the 
    % database columns.  to get the column device_info_serial from 
    % the table as an matlab array type tracks.device_info_serial 
    data = curs1.Data;
    % display notification message
    curs1.message

    %% Close the database connection
    % ( unless running more queries )
    close(conn); 