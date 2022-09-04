% OTA Design Script
% Write the SPECS
clear all;
clc;

AVDC = 34; %dB
GBW = 1e8; %Hz
CL = 500e-15; %Farad
specs = struct('AVDC', AVDC,... 
'CL', CL,...
'GBW', GBW);

OTA = loptOTA(specs);
% Print the solution
fprintf('**** Local opt OTA Design ****\n\n');
fprintf('Input Pair:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    ViCM=%.4f V\n\n',OTA.M1.L,OTA.M1.W,OTA.M1.VG);
fprintf('CM Load:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n\n',OTA.M3.L,OTA.M3.W);
fprintf('Tail Current Source:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n\n',OTA.M5.L,OTA.M5.W);
fprintf('    Optimized current = %.2f uA\n\n', OTA.M5.ID*1e6);

OTA = goptOTA(specs);
% Print the solution
fprintf('**** Global opt OTA Design ****\n\n');
fprintf('Input Pair:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n    ViCM=%.4f V\n\n',OTA.M1.L,OTA.M1.W,OTA.M1.VG);
fprintf('CM Load:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n\n',OTA.M3.L,OTA.M3.W);
fprintf('Tail Current Source:\n');
fprintf('    L = %.2f um\n    W=%.2f um\n\n',OTA.M5.L,OTA.M5.W);
fprintf('    Optimized current = %.2f uA\n\n', OTA.M5.ID*1e6);

