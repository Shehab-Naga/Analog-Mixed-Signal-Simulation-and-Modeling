function OTA = loptOTA(specs)
% inputs in the form of [ M1.L , M3.L , M5.L , M1.RHO , M2.RHO , M3.RHO ,
% IB]
OTA = designOTA(specs);
load 180nch.mat;
load 180pch.mat;
UB = [1, 2.00, 1.5 , 20, 15 , 20, 1e-4];  % upper limits for inputs 
LB = [0.18, 0.18, 0.5, 10 , 10 , 10 ,1e-6];  % lower limits for inputs

% Add line here for inital inputs (X0 = ??)
X0 = [0.28 1.7 1 15 10 10 45.88e-6];
% Add line for the objective function (ObjFn= @ (X) ( ???? )
ObjFn= @ (X) (X(7));
NonLinConFn = @(X)NonLinCon(X, OTA, specs,nch,pch);  %% some lines are missing inside NonLinCon file
% calling fmincon
X = fmincon(ObjFn, X0, [], [], [], [], LB, UB,NonLinConFn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save all variables
% Assign X to the corresponding OTA variables (Same lines as loptOTA)
OTA.M1.L = X(1);
OTA.M3.L = X(2); 
OTA.M5.L = X(3);
OTA.M1.gm_ID = X(4);
OTA.M3.gm_ID = X(5); 
OTA.M5.gm_ID = X(6);
OTA.M5.ID = X(7);
OTA.M3.ID = 0.5*X(7); 
OTA.M1.ID = 0.5*X(7);

OTA.M1.ID_W = look_up(nch, 'ID_W', 'GM_ID', OTA.M1.gm_ID, 'VDS', OTA.M1.VDS, 'L', OTA.M1.L);
OTA.M1.W = OTA.M1.ID / OTA.M1.ID_W;
OTA.M3.ID_W = look_up(pch, 'ID_W', 'GM_ID', OTA.M3.gm_ID, 'VDS', OTA.M3.VDS, 'L', OTA.M3.L);
OTA.M3.W = OTA.M3.ID / OTA.M3.ID_W;
OTA.M5.ID_W = look_up(nch, 'ID_W', 'GM_ID', OTA.M5.gm_ID, 'VDS', OTA.M5.VDS, 'L', OTA.M5.L);
OTA.M5.W = OTA.M5.ID / OTA.M5.ID_W;
OTA.M1.VGS = look_upVGS(nch, 'GM_ID', OTA.M1.gm_ID, 'VDS', OTA.M1.VDS, 'L', OTA.M1.L);
OTA.M1.VG = OTA.M1.VGS + OTA.M5.VDS;




