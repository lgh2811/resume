PROC IMPORT DATAFILE="C:/Users/lgh2811/Desktop/projects/banktrain.csv"
OUT=banktrain DBMS=csv REPLACE;

  GETNAMES=YES;
RUN;

/*check normality of quantitative variables*/
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

/*Over-sampling yes*/
proc sort data=banktrain;
by y;
run;

proc surveyselect data=banktrain out=
sub method=srs rate=(20,100) seed=1111;
strata y;
run;

proc freq data=sub;
tables y;
run;


/*end-of oversampling*/


/*pdays has a lot of outliers and is highly not normal*/

proc discrim data=sub out=discrim_out ;
  class y;
  var balance duration previous;
run;


/*

Linear Discriminant Function for y

                                          Variable            no           yes

                                          Constant      -0.41088      -2.12325
                                          balance      0.0001173     0.0001677
                                          duration       0.00270       0.00656
                                          previous       0.14200       0.33553

*/


PROC IMPORT DATAFILE="C:/Users/lgh2811/Desktop/projects/banktest.csv"
OUT=banktest DBMS=csv REPLACE;
GETNAMES=YES;
RUN;

data testcan;
set banktest;
can1=0.1167*balance+0.9704*duration+0.1784*previous;
can2=0.1144*balance+ 0.9778*duration+0.2113*previous;
run;




data testcan;
set testcan;
if can2>can1 then yhat="no";
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
