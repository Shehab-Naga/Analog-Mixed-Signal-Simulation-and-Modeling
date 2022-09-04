% cleaning the workspace, and cmd window
clear all;
clc;

% running the first SPICE netlist
fprintf('the first netlist:\n');
[sum1,num1]=Solve_Circuit('circuit_1.cir');

fprintf('the second netlist:\n');
% add a line here to run the second netlist
[sum2,num2]=Solve_Circuit('circuit_2.cir');