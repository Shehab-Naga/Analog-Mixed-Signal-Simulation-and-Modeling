
function [C, CEQ] = NonLinConV(X, OTA, specs,nch,pch)

OTA.M1.L = X(:,1);
OTA.M3.L = X(:,2);
OTA.M5.L = X(:,3);
OTA.M1.gm_ID = X(:,4);
OTA.M3.gm_ID = X(:,5);
OTA.M5.gm_ID = X(:,6);   
OTA.M5.ID = X(:,7);
OTA.M1.ID = 0.5*X(:,7);
OTA.M3.ID = 0.5*X(:,7);

OTA.M1.gm = OTA.M1.ID.*OTA.M1.gm_ID;
OTA.M3.gm = OTA.M1.ID.*OTA.M3.gm_ID;


OTA.M1.gm_gds=look_up(nch, 'GM_GDS', 'GM_ID', OTA.M1.gm_ID, 'VDS', OTA.M1.VDS, 'L', OTA.M1.L);
OTA.M1.gm_gds=diag(OTA.M1.gm_gds);
OTA.M1.gds = OTA.M1.gm ./ OTA.M1.gm_gds;
OTA.M3.gm_gds=look_up(pch, 'GM_GDS', 'GM_ID', OTA.M3.gm_ID, 'VDS', OTA.M3.VDS, 'L', OTA.M3.L);
OTA.M3.gm_gds=diag(OTA.M3.gm_gds);
OTA.M3.gds = OTA.M3.gm ./ OTA.M3.gm_gds;
OTA.M1.gm_cdd = look_up(nch, 'GM_CDD', 'GM_ID', OTA.M1.gm_ID, 'VDS', OTA.M1.VDS, 'L',OTA.M1.L);
OTA.M1.gm_cdd =diag(OTA.M1.gm_cdd);
OTA.M3.gm_cdd = look_up(pch, 'GM_CDD', 'GM_ID', OTA.M3.gm_ID, 'VDS', OTA.M3.VDS, 'L',OTA.M3.L);
OTA.M3.gm_cdd =diag(OTA.M3.gm_cdd);
OTA.M1.cdd=OTA.M1.gm ./ OTA.M1.gm_cdd;
OTA.M3.cdd=OTA.M3.gm ./ OTA.M3.gm_cdd;
C_total = OTA.M1.cdd+OTA.M3.cdd+specs.CL;
%% write ouput specs AVDC_OUT , GBW_OUT equations (include self loading )
AVDC_OUT = OTA.M1.gm ./ (OTA.M3.gds + OTA.M1.gds);
GBW_OUT = OTA.M1.gm ./(C_total * 2 * pi);

CEQ = [];
C(:,1) =  10^(specs.AVDC / 20)./ double(AVDC_OUT) - 1;
C(:,2) = specs.GBW ./ double(GBW_OUT) - 1;


