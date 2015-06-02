PROC IMPORT DATAFILE="C:/Users/lgh2811/Desktop/projects/banktrain.csv"
OUT=banktrain DBMS=csv REPLACE;
GETNAMES=YES;
RUN;

proc print data=banktrain(obs=10);
var y;
run;





/*split training dataset to y=yes and y=no*/
DATA Z1; SET banktrain;
IF y="yes";
keep balance duration previous;
RUN;

DATA Z2; SET banktrain;
IF y="no";
keep balance duration previous;
RUN;





DATA Z2; SET banktrain;
IF y="no";
keep balance duration previous;
RUN;


*1.MULTIVARIATE NORMALITY FOR y="no";
title "U vs V plot for y=no"

PROC IML;
USE Z1;
READ ALL INTO Y;
N=NROW(Y);
YBAR=1/N*Y`*J(N,1);
S=1/(N-1)*Y`*(I(N)-1/N*J(N))*Y;
SINV=INV(S);
YB=YBAR*J(1,N,1);
YD=Y-YB`;
DSQ=YD*SINV*YD`;
D=DIAG(DSQ);
D2=D*J(N,1,1);
CREATE SGD FROM D2[COLNAME='D2'];
APPEND FROM D2;

DATA SGD;SET SGD;
PROC SORT; BY D2;
PROC PRINT DATA=SGD;
RUN;

DATA SGD; SET SGD;
N=23966;P=3;
U=N*D2/(N-1)**2;
A=P/2;
B=(N-P-1)/2;
ALPHA=(P-2)/(2*P);
BETA=(N-P-3)/(2*(N-P-1));
PR=(_N_-ALPHA)/(N-ALPHA-BETA+1);
V=BETAINV(PR,A,B);
RUN;

PROC GPLOT DATA=SGD;
PLOT U*V=1;
SYMBOL1 C=RED V=STAR I=RL;
RUN;





*1.MULTIVARIATE NORMALITY FOR y="yes";

PROC IML;
USE Z2;
READ ALL INTO Y;
N=NROW(Y);
YBAR=1/N*Y`*J(N,1);
S=1/(N-1)*Y`*(I(N)-1/N*J(N))*Y;
SINV=INV(S);
YB=YBAR*J(1,N,1);
YD=Y-YB`;
DSQ=YD*SINV*YD`;
D=DIAG(DSQ);
D2=D*J(N,1,1);
CREATE SGD FROM D2[COLNAME='D2'];
APPEND FROM D2;

DATA SGD;SET SGD;
PROC SORT; BY D2;
PROC PRINT DATA=SGD;
RUN;

DATA SGD; SET SGD;
N=3160;P=3;
U=N*D2/(N-1)**2;
A=P/2;
B=(N-P-1)/2;
ALPHA=(P-2)/(2*P);
BETA=(N-P-3)/(2*(N-P-1));
PR=(_N_-ALPHA)/(N-ALPHA-BETA+1);
V=BETAINV(PR,A,B);
RUN;

PROC GPLOT DATA=SGD;
PLOT U*V=1;
SYMBOL1 C=Blue V=STAR I=RL;
RUN;






