%% ============================================================
%  WW3 Parent -> Inner
%  提取 Inner 第二圈 mask=2 的连续开放边界
%  并检查对应位置在 Parent 是否为海点
%
%  Inner : 115-136E, 12-26N, 1/24 deg, 505 x 337
%  Parent: 109-145E,  6-32N, 1/12 deg, 433 x 313
%
%  mask_inner:  505 x 337
%  mask_parent: 433 x 313
%
%  矩阵第一维 = longitude
%       第二维 = latitude


clearvars -except mask_inner mask_parent
clc
load mask
% Inner
lon0_i = 115.0;
lat0_i = 12.0;
dx_i   = 1/24;
dy_i   = 1/24;

nx_i = size(mask_inner,1);
ny_i = size(mask_inner,2);

lon_i = lon0_i + (0:nx_i-1)*dx_i;
lat_i = lat0_i + (0:ny_i-1)*dy_i;


% Parent
lon0_p = 109.0;
lat0_p = 6.0;
dx_p   = 1/12;
dy_p   = 1/12;

nx_p = size(mask_parent,1);
ny_p = size(mask_parent,2);

lon_p = lon0_p + (0:nx_p-1)*dx_p;
lat_p = lat0_p + (0:ny_p-1)*dy_p;

% 1. 提取 Inner 第二圈四条边

% South: j = 2
south_idx = find(mask_inner(2:nx_i-1,2) == 2) + 1;

% North: j = ny-1
north_idx = find(mask_inner(2:nx_i-1,ny_i-1) == 2) + 1;

% West: i = 2
west_idx = find(mask_inner(2,2:ny_i-1) == 2) + 1;

% East: i = nx-1
east_idx = find(mask_inner(nx_i-1,2:ny_i-1) == 2) + 1;


% 2. 找连续的 mask=2 段

south_seg = find_segments(south_idx);
north_seg = find_segments(north_idx);
west_seg  = find_segments(west_idx);
east_seg  = find_segments(east_idx);


% 3. 打印 Inner 实际开放边界

fprintf('\n====================================================\n');
fprintf('INNER OPEN BOUNDARY SEGMENTS\n');
fprintf('====================================================\n');


%South
fprintf('\n--- SOUTH boundary ---\n');

for k = 1:size(south_seg,1)

    i1 = south_seg(k,1);
    i2 = south_seg(k,2);

    fprintf('segment %d:\n',k);
    fprintf('lon = %.7f -> %.7f\n',lon_i(i1),lon_i(i2));
    fprintf('lat = %.7f\n',lat_i(2));
    fprintf('NPTS = %d\n',i2-i1+1);

end


%East
fprintf('\n--- EAST boundary ---\n');

for k = 1:size(east_seg,1)

    j1 = east_seg(k,1);
    j2 = east_seg(k,2);

    fprintf('segment %d:\n',k);
    fprintf('lon = %.7f\n',lon_i(nx_i-1));
    fprintf('lat = %.7f -> %.7f\n',lat_i(j1),lat_i(j2));
    fprintf('NPTS = %d\n',j2-j1+1);

end


%North
fprintf('\n--- NORTH boundary ---\n');

for k = 1:size(north_seg,1)

    i1 = north_seg(k,1);
    i2 = north_seg(k,2);

    fprintf('segment %d:\n',k);
    fprintf('lon = %.7f -> %.7f\n',lon_i(i1),lon_i(i2));
    fprintf('lat = %.7f\n',lat_i(ny_i-1));
    fprintf('NPTS = %d\n',i2-i1+1);

end


%West
fprintf('\n--- WEST boundary ---\n');

for k = 1:size(west_seg,1)

    j1 = west_seg(k,1);
    j2 = west_seg(k,2);

    fprintf('segment %d:\n',k);
    fprintf('lon = %.7f\n',lon_i(2));
    fprintf('lat = %.7f -> %.7f\n',lat_i(j1),lat_i(j2));
    fprintf('NPTS = %d\n',j2-j1+1);

end

% 4. 检查每一个 Inner mask=2 点在 Parent 最近格点是不是海洋

fprintf('\n====================================================\n');
fprintf('CHECK PARENT MASK\n');
fprintf('====================================================\n');

bad_count = 0;

% South boundary: j = 2

for n = 1:length(south_idx)

    ii = south_idx(n);

    lon0 = lon0_i + (ii-1)*dx_i;
    lat0 = lat0_i + (2-1)*dy_i;

    % Parent最近格点
    ip = round((lon0-lon0_p)/dx_p) + 1;
    jp = round((lat0-lat0_p)/dy_p) + 1;

    % 防止超出Parent范围
    ip = max(1,min(nx_p,ip));
    jp = max(1,min(ny_p,jp));

    if mask_parent(ip,jp) ~= 1

        bad_count = bad_count + 1;

        fprintf(['WARNING %4d: South  Inner=(%.6f, %.6f)  ', ...
                 'Parent=(%.6f, %.6f), mask=%d\n'], ...
                 bad_count, ...
                 lon0,lat0, ...
                 lon0_p+(ip-1)*dx_p, ...
                 lat0_p+(jp-1)*dy_p, ...
                 mask_parent(ip,jp));

    end
end

% North boundary: j = ny_i-1

for n = 1:length(north_idx)

    ii = north_idx(n);

    lon0 = lon0_i + (ii-1)*dx_i;
    lat0 = lat0_i + (ny_i-2)*dy_i;

    ip = round((lon0-lon0_p)/dx_p) + 1;
    jp = round((lat0-lat0_p)/dy_p) + 1;

    ip = max(1,min(nx_p,ip));
    jp = max(1,min(ny_p,jp));

    if mask_parent(ip,jp) ~= 1

        bad_count = bad_count + 1;

        fprintf(['WARNING %4d: North  Inner=(%.6f, %.6f)  ', ...
                 'Parent=(%.6f, %.6f), mask=%d\n'], ...
                 bad_count, ...
                 lon0,lat0, ...
                 lon0_p+(ip-1)*dx_p, ...
                 lat0_p+(jp-1)*dy_p, ...
                 mask_parent(ip,jp));

    end
end

% West boundary: i = 2

for n = 1:length(west_idx)

    jj = west_idx(n);

    lon0 = lon0_i + (2-1)*dx_i;
    lat0 = lat0_i + (jj-1)*dy_i;

    ip = round((lon0-lon0_p)/dx_p) + 1;
    jp = round((lat0-lat0_p)/dy_p) + 1;

    ip = max(1,min(nx_p,ip));
    jp = max(1,min(ny_p,jp));

    if mask_parent(ip,jp) ~= 1

        bad_count = bad_count + 1;

        fprintf(['WARNING %4d: West   Inner=(%.6f, %.6f)  ', ...
                 'Parent=(%.6f, %.6f), mask=%d\n'], ...
                 bad_count, ...
                 lon0,lat0, ...
                 lon0_p+(ip-1)*dx_p, ...
                 lat0_p+(jp-1)*dy_p, ...
                 mask_parent(ip,jp));

    end
end


% East boundary: i = nx_i-1

for n = 1:length(east_idx)

    jj = east_idx(n);

    lon0 = lon0_i + (nx_i-2)*dx_i;
    lat0 = lat0_i + (jj-1)*dy_i;

    ip = round((lon0-lon0_p)/dx_p) + 1;
    jp = round((lat0-lat0_p)/dy_p) + 1;

    ip = max(1,min(nx_p,ip));
    jp = max(1,min(ny_p,jp));

    if mask_parent(ip,jp) ~= 1

        bad_count = bad_count + 1;

        fprintf(['WARNING %4d: East   Inner=(%.6f, %.6f)  ', ...
                 'Parent=(%.6f, %.6f), mask=%d\n'], ...
                 bad_count, ...
                 lon0,lat0, ...
                 lon0_p+(ip-1)*dx_p, ...
                 lat0_p+(jp-1)*dy_p, ...
                 mask_parent(ip,jp));

    end
end

% Summary

if bad_count == 0

    fprintf(['All Inner mask=2 boundary points have a ', ...
             'nearest Parent sea point (mask=1).\n']);

else

    fprintf(['%d Inner mask=2 boundary points have a ', ...
             'non-sea nearest Parent point.\n'],bad_count);

end


%%

clc;
clear;
load mask
% Inner grid information
lon0 = 115.0;
lat0 = 12.0;
dx = 1/24;
dy = 1/24;
NX = 505;
NY = 337;

% Final Inner mask=2 boundary segments
%
% South/North:
%   [start_i  end_i]
%
% West/East:
%   [start_j  end_j]
% ============================================================

south_seg = [ ...
      2   117;
    255   504];

north_seg = [ ...
    117   388;
    396   504];

west_seg = [ ...
      2   259];

east_seg = [ ...
      2   336];

% Coordinates of the second-ring boundary

j_south = 2;
j_north = NY - 1;
i_west  = 2;
i_east  = NX - 1;
lat_south = lat0 + (j_south-1)*dy;
lat_north = lat0 + (j_north-1)*dy;
lon_west  = lon0 + (i_west-1)*dx;
lon_east  = lon0 + (i_east-1)*dx;
fprintf('\nInner second-ring boundary coordinates:\n');
fprintf('South = %.10f N\n',lat_south);
fprintf('North = %.10f N\n',lat_north);
fprintf('West  = %.10f E\n',lon_west);
fprintf('East  = %.10f E\n\n',lon_east);

% Generate the 6 WW3 output-boundary lines
%
% Format:
%
% X0  Y0  DX  DY  NPTS
%
% ============================================================
B = [];
% Along longitude:
% DX = 1/24
% DY = 0

for k = 1:size(south_seg,1)
    i1 = south_seg(k,1);
    i2 = south_seg(k,2);
    x0 = lon0 + (i1-1)*dx;
    y0 = lat_south;
    npts = i2-i1+1;
    B(end+1,:) = [x0 y0 dx 0 npts];
end

% Along longitude:
% DX = 1/24
% DY = 0

for k = 1:size(north_seg,1)
    i1 = north_seg(k,1);
    i2 = north_seg(k,2);
    x0 = lon0 + (i1-1)*dx;
    y0 = lat_north;
    npts = i2-i1+1;
    B(end+1,:) = [x0 y0 dx 0 npts];
end

% Along latitude:
% DX = 0
% DY = 1/24
for k = 1:size(west_seg,1)
    j1 = west_seg(k,1);
    j2 = west_seg(k,2);
    x0 = lon_west;
    y0 = lat0 + (j1-1)*dy;
    npts = j2-j1+1;
    B(end+1,:) = [x0 y0 0 dy npts];
end

% Along latitude:
% DX = 0
% DY = 1/24
for k = 1:size(east_seg,1)
    j1 = east_seg(k,1);
    j2 = east_seg(k,2);
    x0 = lon_east;
    y0 = lat0 + (j1-1)*dy;
    npts = j2-j1+1;
    B(end+1,:) = [x0 y0 0 dy npts];
end


% Display result
% ============================================================
fprintf('WW3 Parent Output boundary points:\n\n');
fprintf('       X0             Y0             DX             DY      NPTS\n');
for k = 1:size(B,1)
    fprintf('%14.8f %14.8f %14.10f %14.10f %6d\n',...
        B(k,1),B(k,2),B(k,3),B(k,4),round(B(k,5)));
end

% Write to txt file
% ============================================================
output_file = 'parent_output_boundary.txt';
fid = fopen(output_file,'w');
fprintf(fid,'$ Output boundary points --------------------------------------------- $\n');
fprintf(fid,'$     X0             Y0             DX             DY       NPTS\n');
fprintf(fid,'$\n');
for k = 1:size(B,1)
    fprintf(fid,...
        ' %14.8f %14.8f %14.10f %14.10f %6d\n',...
        B(k,1),...
        B(k,2),...
        B(k,3),...
        B(k,4),...
        round(B(k,5)));
end

fprintf(fid,'$\n');
fprintf(fid,'$ Close list by defining line with 0 points (mandatory)\n');
fprintf(fid,'$\n');
fprintf(fid,...
    ' %14.1f %14.1f %14.1f %14.1f %6d\n',...
    0,0,0,0,0);
fclose(fid);
fprintf('\nFile written successfully:\n');
fprintf('%s\n',output_file);


%%
function seg = find_segments(idx)

    if isempty(idx)
        seg = [];
        return
    end

    idx = idx(:);

    cut = find(diff(idx) > 1);

    start_idx = [1; cut+1];
    end_idx   = [cut; length(idx)];

    seg = [idx(start_idx), idx(end_idx)];

end


