function OTA = goptOTA(specs)
% inputs in the form of [ M1.L , M3.L , M5.L , M1.RHO , M2.RHO , M3.RHO ,
% IB]
OTA = designOTA(specs);
load 180nch.mat;
load 180pch.mat;
UB = [0.5, 2.00, 1.5 , 20, 15 , 20, 1e-4];  % upper limits for inputs 
LB = [0.18, 1, 0.5, 10 , 10 , 10 ,1e-6];  % lower limits for inputs


ObjFn = @(X)(X(:,7)); %% vectorized objective function
NonLinConFn = @(X)NonLinConV(X, OTA, specs,nch,pch);
% calling fmincon
options=optimoptions('ga','UseVectorized',true,'PopulationSize',20);
X = ga(ObjFn, 7, [], [], [], [], LB, UB,NonLinConFn,options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save all variables
% Assign X to the corresponding OTA variables , for example:
OTA.M1.L = X(1);
OTA.M3.L = X(2); 
OTA.M5.L = X(3);
OTA.M1.gm_ID = X(4);
OTA.M3.gm_ID = X(5); 
OTA.M5.gm_ID = X(6);
OTA.M5.ID = X(7);
OTA.M3.ID = 0.5*X(7); 
OTA.M1.ID = 0.5*X(7);
% continue the rest (multiple lines)
% note that if you did not write the lines , the values from the previous lab will be used automaticlly
OTA.M1.ID_W = look_up(nch, 'ID_W', 'GM_ID', OTA.M1.gm_ID, 'VDS', OTA.M1.VDS, 'L', OTA.M1.L);
OTA.M1.W = OTA.M1.ID / OTA.M1.ID_W;
OTA.M3.ID_W = look_up(pch, 'ID_W', 'GM_ID', OTA.M3.gm_ID, 'VDS', OTA.M3.VDS, 'L', OTA.M3.L);
OTA.M3.W = OTA.M3.ID / OTA.M3.ID_W;
OTA.M5.ID_W = look_up(nch, 'ID_W', 'GM_ID', OTA.M5.gm_ID, 'VDS', OTA.M5.VDS, 'L', OTA.M5.L);
OTA.M5.W = OTA.M5.ID / OTA.M5.ID_W;
OTA.M1.VGS = look_upVGS(nch, 'GM_ID', OTA.M1.gm_ID, 'VDS', OTA.M1.VDS, 'L', OTA.M1.L);
OTA.M1.VG = OTA.M1.VGS + OTA.M5.VDS;




