clear; clc;
gebco_file = 'E:\ph_study\ph_data\topo\GEBCO_2019.nc';
out_dir = 'D:\ph_study\WW3\';

%  1. WW3 target grid
lon_min = 115.0;
lon_max = 136.0;
lat_min = 12.0;
lat_max = 26.0;
dx = 1/24;
dy = 1/24;
lon_ww3 = lon_min:dx:lon_max;
lat_ww3 = lat_min:dy:lat_max;
nx = length(lon_ww3);
ny = length(lat_ww3);
fprintf('WW3 grid:\n');
fprintf('NX = %d\n',nx);
fprintf('NY = %d\n',ny);
fprintf('Lon = %.8f -- %.8f\n',lon_ww3(1),lon_ww3(end));
fprintf('Lat = %.8f -- %.8f\n\n',lat_ww3(1),lat_ww3(end));


%  2. Read GEBCO coordinates
lon = ncread(gebco_file,'lon');
lat = ncread(gebco_file,'lat');

%  3. Find regional subset
%  Add a margin because interpolation needs surrounding points
margin = 0.1;
ix = find(lon >= lon_min-margin & lon <= lon_max+margin);
iy = find(lat >= lat_min-margin & lat <= lat_max+margin);
ix1 = ix(1);
ix2 = ix(end);
iy1 = iy(1);
iy2 = iy(end);
fprintf('GEBCO subset:\n');
fprintf('ix = %d -- %d\n',ix1,ix2);
fprintf('iy = %d -- %d\n',iy1,iy2);
fprintf('Lon = %.8f -- %.8f\n',lon(ix1),lon(ix2));
fprintf('Lat = %.8f -- %.8f\n',lat(iy1),lat(iy2));


%  4. Read ONLY regional elevation
%  GEBCO variable dimensions in MATLAB/ncread need to be checked
%  against ncinfo. elevation is stored as elevation(lat,lon)
%  in ncdump, while MATLAB may expose dimension order differently.
info = ncinfo(gebco_file,'elevation');
disp('MATLAB dimension information for elevation:')
disp(info.Size)
% ncread start/count follow MATLAB's ncinfo dimension ordering.
% For this GEBCO file this should normally be lon x lat in MATLAB.
elev = ncread(gebco_file,'elevation', ...
              [ix1 iy1], ...
              [ix2-ix1+1 iy2-iy1+1]);
          
lon_sub = lon(ix1:ix2);
lat_sub = lat(iy1:iy2);
fprintf('\nRegional elevation size:\n');
disp(size(elev));
fprintf('Elevation min = %.2f m\n',min(elev(:)));
fprintf('Elevation max = %.2f m\n',max(elev(:)));

%  5. Interpolate GEBCO elevation to WW3 grid
[x1,y1] = meshgrid(lon_ww3,lat_ww3);
[x2,y2] = meshgrid(lon_sub,lat_sub);
% elev should correspond to lon x lat here
elev_ww3 = interp2(x2,y2,double(elev'),x1',y1');

fprintf('\nInterpolated WW3 elevation:\n');
fprintf('Size = %d x %d\n',size(elev_ww3,1),size(elev_ww3,2));
fprintf('Min  = %.2f m\n',min(elev_ww3(:)));
fprintf('Max  = %.2f m\n',max(elev_ww3(:)));

%  6. Convert elevation to ocean depth
%  GEBCO:
%     ocean: elevation < 0
%     land : elevation >= 0
%
%  WW3 depth:
%     ocean depth < 0
depth_ww3 = elev_ww3;

%  7. Preliminary land-sea mask
%  1 = ocean
%  0 = land
%  This is a preliminary mask for inspection.
mask_ww3 = zeros(size(elev_ww3));
mask_ww3(elev_ww3 < 0) = 1;
mask_ww3(elev_ww3 >= 0) = 0;
% Set land depth to zero for inspection/output preparation
depth_ww3(mask_ww3 == 0) = 0;


% %  7b. Minimum ocean depth，先不处理，WW3内部会处理？
% dmin = 10.0;   % m
% depth_ww3(mask_ww3 == 1 & depth_ww3 < dmin) = dmin;
% fprintf('\nAfter minimum-depth treatment:\n');
% fprintf('Minimum ocean depth = %.2f m\n', ...
%         min(depth_ww3(mask_ww3 == 1)));
% 
% fprintf('Maximum ocean depth = %.2f m\n', ...
%         max(depth_ww3(mask_ww3 == 1)));

%%
%  Generate WW3 mask
%  WW3 mask:
%    0 = land / inactive
%    1 = active sea point
%    2 = active boundary point
%
%  Outer grid lines are inactive.
%  Open boundary points are placed on the second grid line.

mask_final = mask_ww3;
[nx,ny] = size(mask_final);
fprintf('Grid size: nx = %d, ny = %d\n',nx,ny);

% 1. Set the outermost grid lines to inactive
% mask_final(1,:)   = 0;       % West outer edge
% mask_final(nx,:)  = 0;       % East outer edge
% mask_final(:,1)   = 0;       % South outer edge
% mask_final(:,ny)  = 0;       % North outer edge

% 2. Set ocean points on the second grid line as open boundary
%West boundary: i = 2
% jj = find(mask_final(2, 2:ny-1) == 1);
% jj = jj + 1;
% mask_final(2, jj) = 2;
% % East boundary: i = nx-1
% jj = find(mask_final(nx-1, 2:ny-1) == 1);
% jj = jj + 1;
% mask_final(nx-1, jj) = 2;
% % South boundary: j = 2
% ii = find(mask_final(2:nx-1, 2) == 1);
% ii = ii + 1;
% mask_final(ii, 2) = 2;
% % North boundary: j = ny-1
% ii = find(mask_final(2:nx-1, ny-1) == 1);
% ii = ii + 1;
% mask_final(ii, ny-1) = 2;
% 
% %南边界mask处理
% ii = find(mask_final(118:254,2) == 2);
% ii = ii + 117;
% mask_final(ii,2) = 1;
% 
% %北边界mask处理，右
% ii = find(mask_final(389:395,336) == 2);
% ii = ii + 388;
% mask_final(ii,336) = 1;
% 
% %北边界mask处理，左
% ii = find(mask_final(2:116,336) == 2);
% ii = ii + 1;
% mask_final(ii,336) = 1;
% 
% %西边界mask处理
% ii = find(mask_final(2,257:260) == 2);
% ii = ii + 256;
% mask_final(2,ii) = 1;



figure
imagesc(lon_ww3,lat_ww3,mask_final');
set(gca,'YDir','normal');
axis equal tight
colorbar
caxis([0 2]);
xlabel('Longitude (^oE)')
ylabel('Latitude (^oN)')
title('WW3 grid mask')
set(gca,'FontSize',12);

% load mask
% save('mask','mask_parent','mask_inner')

% 5. Write mask_SCS.dat
%
% IDLA = 1:
% bottom -> top
% South -> North
%
% Each row:
% West -> East
% ------------------------------------------------------------

mask_file = ...
'D:\ph_study\WW3\mask_SCS.dat';
fid = fopen(mask_file,'w');
if fid < 0
    error('Cannot open mask_SCS.dat');
end
for j = 1:ny
    for i = 1:nx
        fprintf(fid,'%2d ',mask_final(i,j));
    end
    fprintf(fid,'\n');
end
fclose(fid);
fprintf('\nmask file written:\n%s\n',mask_file);


%生成 WW3 boundary list
fid = fopen('ww3_boundary.inp','w');
[nx,ny]=size(mask_final);
count=0;
for j=1:ny
    for i=1:nx      
        if mask_final(i,j)==2          
            fprintf(fid,'%6d %6d\n',i,j);
            count=count+1;         
        end        
    end
end
fclose(fid);
fprintf('Boundary points = %d\n',count);


%%
%depth_SCS.dat
depth_file = [out_dir,'depth_SCS.dat'];
fid = fopen(depth_file,'w');
for j = 1:ny
    for i = 1:nx
        fprintf(fid,'%10.2f ',depth_ww3(i,j));
    end
    fprintf(fid,'\n');
end
fclose(fid);
fprintf('Saved: %s\n',depth_file);


% save([out_dir,'SCS_bathymetry.mat'], ...
%      'lon_ww3','lat_ww3','elev_ww3', ...
%      'depth_ww3','mask_ww3','mask_final');

depth_ww3=depth_ww3';
num_nonzero = sum(depth_ww3(:) ~= 0);
%最终的水深文件陆地全部设为0，没有处理最小水深，且水深为负值





