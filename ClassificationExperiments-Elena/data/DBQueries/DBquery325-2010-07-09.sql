SELECT a.*,(a.x_acceleration-d.x_o)/d.x_s as x_cal, 
               (a.y_acceleration-d.y_o)/d.y_s as y_cal,
               (a.z_acceleration-d.z_o)/d.z_s as z_cal 
 FROM gps.uva_acceleration101 as a                join gps.uva_device d 
               ON a.device_info_serial = d.device_info_serial where a.device_info_serial=325 and date_time between '2010-07-9 00:13:48'
 and '2011-07-09 11:01:05' order by date_time, index


 