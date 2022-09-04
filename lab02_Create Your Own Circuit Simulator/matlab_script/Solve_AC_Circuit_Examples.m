% cleaning the workspace, and cmd window
clear all;
clc;

[sym1,num1]=Solve_AC_Circuit('RLC_underDamped.cir'); 
[sym2,num2]=Solve_AC_Circuit('RLC_criticalDamped.cir'); 
[sym3,num3]=Solve_AC_Circuit('RLC_overdamped.cir'); 
