%%
%这个脚本用于生成ww3所需的wind.nc
clc;
clear all;
fclose all;
% ncinfo('D:\ph_study\hycomcode\WW3-6.07.1\data_regtests\ww3_tp2.15\input\wind.nc');
% time_ww3=ncread('D:\ph_study\hycomcode\WW3-6.07.1\data_regtests\ww3_tp2.15\input\wind.nc','time');
% lon_ww3=ncread('D:\ph_study\hycomcode\WW3-6.07.1\data_regtests\ww3_tp2.15\input\wind.nc','longitude');
% lat_ww3=ncread('D:\ph_study\hycomcode\WW3-6.07.1\data_regtests\ww3_tp2.15\input\wind.nc','latitude');
% U_ww3=ncread('D:\ph_study\hycomcode\WW3-6.07.1\data_regtests\ww3_tp2.15\input\wind.nc','U');
% V_ww3=ncread('D:\ph_study\hycomcode\WW3-6.07.1\data_regtests\ww3_tp2.15\input\wind.nc','V');

%转换成ww3所需格式的经纬度
load uv10m_2023.mat
[longitude,latitude]=meshgrid(lon,lat);
longitude=longitude';
latitude=latitude';

%转换成ww3所需格式的时间变量
day = floor(MT);
hour = (MT-day)*24;
date0 = datetime(2023,1,1);
time_date = date0 + days(day-44561)+hours(hour);
base = datetime(1900,1,1);
time = seconds(time_date-base);

%写入nc文件
output_nc = 'wind.nc';  % 输出的新的 NetCDF 文件
ncid = netcdf.create(output_nc, 'NETCDF4');
time_dim = netcdf.defDim(ncid, 'time', length(time));
lat_dim = netcdf.defDim(ncid, 'latitude', length(latitude(1,:)));  % 纬度维度
lon_dim = netcdf.defDim(ncid, 'longitude', length(longitude(:,1)));  % 经度维度

time_var = netcdf.defVar(ncid, 'time', 'double', time_dim);
lon_var = netcdf.defVar(ncid, 'longitude', 'double', [lon_dim, lat_dim]); 
lat_var = netcdf.defVar(ncid, 'latitude', 'double', [lon_dim, lat_dim]); 
U_var = netcdf.defVar(ncid, 'U', 'double', [lon_dim, lat_dim,time_dim]); 
V_var = netcdf.defVar(ncid, 'V', 'double', [lon_dim, lat_dim,time_dim]); 

netcdf.putAtt(ncid, U_var, '_FillValue', 3276800.0);
netcdf.putAtt(ncid, V_var, '_FillValue', 3276800.0);

netcdf.endDef(ncid);

% 写入全局属性
ncwriteatt(output_nc, '/', 'start_date', '2023-01-01 00:00:00');
ncwriteatt(output_nc, '/', 'stop_date', '2023-12-31 21:00:00');
ncwriteatt(output_nc, '/', 'source', 'NRL .D forcing file');
ncwriteatt(output_nc, '/', 'field type', 'hourly');
ncwriteatt(output_nc, '/', 'content', '10-meter wind components');
ncwriteatt(output_nc, '/', 'NCO', 'netCDF Operators version 4.7.5 (Homepage = http://nco.sf.net, Code = http://github.com/nco/nco)');

% 写入变量属性

ncwriteatt(output_nc, 'time', 'long_name', 'time');
ncwriteatt(output_nc, 'time', 'units', 'seconds since 1900-01-01 00:00:00');
ncwriteatt(output_nc, 'time', 'field', 'time, scalar, series');

ncwriteatt(output_nc, 'longitude', 'long_name', 'Longitude of grid nodes');
ncwriteatt(output_nc, 'longitude', 'units', 'degE');
ncwriteatt(output_nc, 'longitude', 'field', 'lon, scalar, series');

ncwriteatt(output_nc, 'latitude', 'long_name', 'Latitude of grid nodes');
ncwriteatt(output_nc, 'latitude', 'units', 'degN');
ncwriteatt(output_nc, 'latitude', 'field', 'lat, scalar, series');

ncwriteatt(output_nc, 'U', 'units', 'm/s');
ncwriteatt(output_nc, 'U', 'field', 'U, scalar, series');
ncwriteatt(output_nc, 'U', 'scale_factor', 0.010000000000000);
ncwriteatt(output_nc, 'U', 'long_name', '10-meter wind East component');

ncwriteatt(output_nc, 'V', 'units', 'm/s');
ncwriteatt(output_nc, 'V', 'field', 'V, scalar, series');
ncwriteatt(output_nc, 'V', 'scale_factor', 0.010000000000000);
ncwriteatt(output_nc, 'V', 'long_name', '10-meter wind North component');

% 写入数据
netcdf.putVar(ncid, time_var, time);  % 写入时间数据
netcdf.putVar(ncid, lat_var, latitude);  % 写入纬度数据
netcdf.putVar(ncid, lon_var, longitude);  % 写入经度数据

t1_scaled = (wndewd - 0) / 0.01;
netcdf.putVar(ncid, U_var, t1_scaled);  % 写入缩放后的数据
t2_scaled = (wndnwd - 0) / 0.01;
netcdf.putVar(ncid, V_var, t2_scaled);  % 写入缩放后的数据

% 关闭 NetCDF 文件
netcdf.close(ncid);



%%
%验证
clc;
clear all;
fclose all;
ncinfo('wind.nc')
time_ww3=ncread('wind.nc','time');
lon_ww3=ncread('wind.nc','longitude');
lat_ww3=ncread('wind.nc','latitude');
U_ww3=ncread('wind.nc','U');
V_ww3=ncread('wind.nc','V');
load uv10m_2023.mat

aa=U_ww3(:,:,1);
bb=wndewd(:,:,1);




















