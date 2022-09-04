% OTA Design Script
% Write the SPECS
clear all;
clc;
AVDC = 34; % complete the line to add the gain SPEC
GBW = 100e+6; % complete the line to add the GBW SPEC
CL = 500e-15 + 44.09e-15 + 3.603e-15; % complete the line to add the CL SPEC
specs = struct('AVDC', AVDC,... 
'CL', CL,...
'GBW', GBW);
% struct('AVDC', 50.1187,'CL', 500e-15,'GBW', 100e+6)
OTA = designOTA2(specs);
% Print the solution
fprintf('**** OTA Design ****\n\n');
fprintf('Input Pair:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    ViCM=%.4f V\n\n',OTA.M1.L,OTA.M1.W,OTA.M1.VG);
fprintf('CM Load:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n\n',OTA.M3.L,OTA.M3.W);
fprintf('Tail Current Source:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n\n',OTA.M5.L,OTA.M5.W);

