% Lookup Test
% Please copy this script to gm/ID starter directory & run it from there
% Clear workspace
clear all;
clc;

%load LUTs
load 180nch.mat;
load 180pch.mat;

% Compute VGS & ID
% Givens
VDD = 1.8;
M1.gm_ID = 10;
M1.gm_gds = 50;
M1.VDS = VDD / 3;
M1.VSB = 0;
M1.W = 5;
M1.gm_gds = 50;
% Find L that give gm/gds > given value
L_vector = nch.L; % Get the L vector from LUT structure
%Get the gm/gds values vector corresponding to the L_vector
gm_gds_vector = look_up(nch, 'GM_GDS', 'GM_ID', M1.gm_ID, 'VDS', M1.VDS, 'L', L_vector);
% Get the minimum L that gives gm/gds > the given value
% add line to get the minimum L for M1 that gives gm/gds >= M1.gm_gds 
M1.L = min(L_vector(find(gm_gds_vector >= M1.gm_gds)));
% Get the current by computing the ID/W and then multiply it by W
M1.ID_W = look_up(nch, 'ID_W', 'GM_ID', M1.gm_ID, 'VDS', M1.VDS, 'L', M1.L);
% add line to get the current of M1
M1.ID = M1.ID_W*M1.W;
% Get the VGS value
% add line to get the VGS value of M1
M1.VGS = look_upVGS(nch, 'GM_ID', M1.gm_ID, 'VDS', M1.VDS, 'L', M1.L);
% Print the solution
fprintf('VGS = %.2f\n',M1.VGS);
fprintf('ID = %.2d\n',M1.ID);