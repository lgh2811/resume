PROC IMPORT DATAFILE="C:/Users/lgh2811/Desktop/projects/banktrain.csv"
OUT=banktrain DBMS=csv REPLACE;

  GETNAMES=YES;
RUN;

/*check normality of quantitative variables*/
ods html;
proc univariate data=banktrain;
histogram;
class y;
var balance duration pdays previous;
run;



proc print data=banktrain (obs=10);
run;

proc contents data=banktrain;
run;


proc means data=banktrain n mean std min max;
run;

proc means data=banktrain n mean std;
  class y;
run;

proc corr data=banktrain;
var balance duration pdays previous;
run;


proc freq data=banktrain;
tables y;
run;

/*pdays has a lot of outliers and is highly not normal*/
proc candisc data=banktrain out=discrim_out ;
  class y;
  var balance duration previous;
run;


/*

Pooled Within-Class Standardized Canonical Coefficients

                                               balance           0.116739
                                               duration          0.970442
                                               previous          0.178430

                                               balance       0.1143991974
                                               duration      0.9778367892
                                               previous      0.2113499180

*/

proc discrim data=banktrain out=discrim_out ;
  class y;
  var balance duration previous;
run;

/*
Linear Discriminant Function for y

                                          Variable            no           yes

                                          Constant      -0.55997      -2.98185
                                          balance      0.0001394     0.0001925
                                          duration       0.00404       0.00991
                                          previous       0.08928       0.20650


*/



PROC IMPORT DATAFILE="C:/Users/lgh2811/Desktop/projects/banktest.csv"
OUT=banktest DBMS=csv REPLACE;
GETNAMES=YES;
RUN;

data testcan;
set banktest;
canno= -0.55997+0.0001394*balance+0.00404*duration+0.08928*previous;
canyes= -2.98185+0.0001925*balance+0.00991*duration+0.20650*previous;
run;

/*convert yes to 1 nd no to 0*/


data testcan;
set testcan;
if canno>canyes then yhat="no";
else yhat="yes";
run;

data pred(keep=y yhat);
set testcan;
run;

proc print data=pred (obs=10);
run;

/*confusion matrix*/

proc freq;
tables y*yhat;
run;






















data plotclass;
  merge fake_out discrim_out;
run;


proc template;
  define statgraph classify;
    begingraph;
      layout overlay;
        contourplotparm x=Can1 y=Can2 z=_into_ / contourtype=fill
                                     nhint = 30 gridded = false;
        scatterplot x=Can1 y=Can2 / group=job includemissinggroup=false
                                 markercharactergroup = job;
      endlayout;
    endgraph;
  end;
run;

proc sgrender data = plotclass template = classify;
run;
