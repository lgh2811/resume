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
                                                                                                                                        
/*SAS Macro variable for proportion of nos*/                                                                                            
%let nonum=10;                                                                                                                          
proc surveyselect data=banktrain out=                                                                                                   
sub method=srs rate=(&nonum,100) seed=1111;                                                                                             
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
                                                                                                                                        
proc print data=discrim_out;                                                                                                            
run;                                                                                                                                    
                                                                                                                                        
                                                                                                                                        
/*                                                                                                                                      
                                                                                                                                        
                                                                                                                                        
                                           Linear Discriminant Function for y                                                           
                                                                                                                                        
                                          Variable            no           yes                                                          
                                                                                                                                        
                                          Constant      -0.35575      -1.79478                                                          
                                          balance      0.0001239     0.0001619                                                          
                                          duration       0.00218       0.00544                                                          
                                          previous       0.12877       0.29956                                                          
                                                                                                                                        
*/                                                                                                                                      
                                                                                                                                        
                                                                                                                                        
PROC IMPORT DATAFILE="C:/Users/lgh2811/Desktop/projects/banktest.csv"                                                                   
OUT=banktest DBMS=csv REPLACE;                                                                                                          
GETNAMES=YES;                                                                                                                           
RUN;                                                                                                                                    
                                                                                                                                        
                                                                                                                                        
data testcan;                                                                                                                           
set banktest;                                                                                                                           
can1=-0.35575+0.0001239*balance+0.00218*duration+0.12877*previous;                                                                      
can2= -1.79478 +0.0001619*balance+0.00544 *duration+0.29956 *previous;                                                                  
run;                                                                                                                                    
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
data testcan;                                                                                                                           
set testcan;                                                                                                                            
if can2>can1 then yhat="yes";                                                                                                           
else yhat="no";                                                                                                                         
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

proc corr data=banktrain cov noprob;
var balance duration previous;
by y;
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

/*SAS Macro variable for proportion of nos*/
%let nonum=10;
proc surveyselect data=banktrain out=
sub method=srs rate=(&nonum,100) seed=1111;
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

proc print data=discrim_out;
run;


/*


                                           Linear Discriminant Function for y

                                          Variable            no           yes

                                          Constant      -0.35575      -1.79478
                                          balance      0.0001239     0.0001619
                                          duration       0.00218       0.00544
                                          previous       0.12877       0.29956

*/


PROC IMPORT DATAFILE="C:/Users/lgh2811/Desktop/projects/banktest.csv"
OUT=banktest DBMS=csv REPLACE;
GETNAMES=YES;
RUN;


data testcan;
set banktest;
can1=-0.35575+0.0001239*balance+0.00218*duration+0.12877*previous;
can2= -1.79478 +0.0001619*balance+0.00544 *duration+0.29956 *previous;
run;


data testcan;
set testcan;
if can2>can1 then yhat="yes";
else yhat="no";
run;


data canscore;
set testcan;
probyes=exp(can2)/(exp(can1)+exp(can2));
keep probyes y;
run;

data canscore;
set canscore;
if y="yes" then y=1;
else y=0;
run;


proc sort data=canscore;
by descending probyes;
run;

ODS RTF FILE="C:/Users/lgh2811/Desktop/projects/lift";
PROC PRINT DATA=canscore;
RUN;
ODS RTF CLOSE;



proc print data=canscore(obs=10);
run;


data pred(keep=y yhat);
set testcan;
run;



/*confusion matrix*/

proc freq data=pred;
tables y*yhat/ nopercent nocol;
run;

proc gplot data=testcan;
plot can1*can2=y;
plot2 can1*can2;
SYMBOL1 C=RED V=STAR;
SYMBOL2 C=BLUE V=PLUS;
run;
