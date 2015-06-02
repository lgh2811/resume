options nomprint mlogic symbolgen;                                                                                                      
/*************************************************                                                                                      
Percentile Capping / Winsorize macro                                                                                                    
*input = dataset to winsorize;                                                                                                          
*output = dataset to output with winsorized values;                                                                                     
*class = grouping variables to winsorize;                                                                                               
* Specify "none" in class for no grouping variable;                                                                                     
*vars = Specify variable(s) in which you want values to be capped;                                                                      
*pctl = define lower and upper percentile - acceptable range;                                                                           
**************************************************/                                                                                     
                                                                                                                                        
%macro pctlcap(input=, output=, class=none, vars=, pctl=1 99);                                                                          
                                                                                                                                        
%if &output = %then %let output = &input;                                                                                               
                                                                                                                                        
%let varL=;                                                                                                                             
%let varH=;                                                                                                                             
%let xn=1;                                                                                                                              
                                                                                                                                        
%do %until (%scan(&vars,&xn)= );                                                                                                        
%let token = %scan(&vars,&xn);                                                                                                          
%let varL = &varL &token.L;                                                                                                             
%let varH = &varH &token.H;                                                                                                             
%let xn=%EVAL(&xn + 1);                                                                                                                 
%end;                                                                                                                                   
                                                                                                                                        
%let xn=%eval(&xn-1);                                                                                                                   
                                                                                                                                        
data xtemp;                                                                                                                             
set &input;                                                                                                                             
run;                                                                                                                                    
                                                                                                                                        
%if &class = none %then %do;                                                                                                            
                                                                                                                                        
data xtemp;                                                                                                                             
set xtemp;                                                                                                                              
xclass = 1;                                                                                                                             
run;                                                                                                                                    
                                                                                                                                        
%let class = xclass;                                                                                                                    
%end;                                                                                                                                   
                                                                                                                                        
proc sort data = xtemp;                                                                                                                 
by &class;                                                                                                                              
run;                                                                                                                                    
                                                                                                                                        
proc univariate data = xtemp noprint;                                                                                                   
by &class;                                                                                                                              
var &vars;                                                                                                                              
output out = xtemp_pctl PCTLPTS = &pctl PCTLPRE = &vars PCTLNAME = L H;                                                                 
run;                                                                                                                                    
                                                                                                                                        
data &output;                                                                                                                           
merge xtemp xtemp_pctl;                                                                                                                 
by &class;                                                                                                                              
array trimvars{&xn} &vars;                                                                                                              
array trimvarl{&xn} &varL;                                                                                                              
array trimvarh{&xn} &varH;                                                                                                              
                                                                                                                                        
do xi = 1 to dim(trimvars);                                                                                                             
if not missing(trimvars{xi}) then do;                                                                                                   
if (trimvars{xi} < trimvarl{xi}) then trimvars{xi} = trimvarl{xi};                                                                      
if (trimvars{xi} > trimvarh{xi}) then trimvars{xi} = trimvarh{xi};                                                                      
end;                                                                                                                                    
end;                                                                                                                                    
drop &varL &varH xclass xi;                                                                                                             
run;                                                                                                                                    
                                                                                                                                        
%mend pctlcap;                                                                                                                          
                                                                                                                                        
PROC IMPORT DATAFILE="C:/Users/lgh2811/Desktop/projects/banktrain.csv"                                                                  
OUT=banktrain DBMS=csv REPLACE;                                                                                                         
GETNAMES=YES;                                                                                                                           
RUN;                                                                                                                                    
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
%pctlcap(input=banktrain, output=winsor, class=y, vars = balance duration previous, pctl=1 99);                                         
                                                                                                                                        
/*using outliers function to trim variables*/                                                                                           
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
proc standard data=winsor out=winsor mean=0 std=1;                                                                                      
var balance duration previous;                                                                                                          
run;                                                                                                                                    
                                                                                                                                        
                                                                                                                                        
proc sql outobs=100;                                                                                                                    
select banktrain.balance, winsor.balance from banktrain join winsor on banktrain._=winsor._ ;                                           
quit;                                                                                                                                   
                                                                                                                                        
                                                                                                                                        
/*credit to contributor of the macro: /*http://www.listendata.com/2015/01/detecting-and-solving-problem-of-outlier.html*/               
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
                                                                                                                                        
/*training of discriminant functions for winsored dataset*/                                                                             
                                                                                                                                        
/*Over-sampling yes*/                                                                                                                   
proc sort data=winsor;                                                                                                                  
by y;                                                                                                                                   
run;                                                                                                                                    
                                                                                                                                        
/*SAS Macro variable for proportion of nos*/                                                                                            
%let nonum=0.4;                                                                                                                         
proc surveyselect data=winsor out=sub                                                                                                   
method=srs rate=(&nonum,100) seed=1234;                                                                                                 
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
                                                                                                                                        
                                          Constant      -0.01365      -0.81559                                                          
                                          balance       -0.03642       0.20017                                                          
                                          duration      -0.15233       1.18444                                                          
                                          previous      -0.05573       0.45860                                                          
                                                                                                                                        
*/                                                                                                                                      
                                                                                                                                        
                                                                                                                                        
PROC IMPORT DATAFILE="C:/Users/lgh2811/Desktop/projects/banktest.csv"                                                                   
OUT=banktest DBMS=csv REPLACE;                                                                                                          
GETNAMES=YES;                                                                                                                           
RUN;                                                                                                                                    
                                                                                                                                        
/*standardize variables*/                                                                                                               
proc standard data=banktest out=banktest mean=0 std=1;                                                                                  
var balance duration previous;                                                                                                          
run;                                                                                                                                    
                                                                                                                                        
                                                                                                                                        
data testcan;                                                                                                                           
set banktest;                                                                                                                           
can1= -0.01365-0.03642*balance-0.15233*duration-0.05573*previous;                                                                       
can2=-0.81559+0.20017 *balance+1.18444*duration+0.45860*previous;                                                                       
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
                                                                                                                                        
proc freq data=pred;                                                                                                                    
tables y*yhat/ nopercent nocol;                                                                                                         
run;                                                                                                                                    
                                                                                                                                        
proc gplot data=testcan;                                                                                                                
plot can1*can2=y;                                                                                                                       
SYMBOL1 C=red V=STAR;                                                                                                                   
SYMBOL2 C=blue V=PLUS;                                                                                                                  
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
                                                                                                                                        
                                                                                                                                        
proc export data=canscore                                                                                                               
   outfile="C:/Users/lgh2811/Desktop/projects/lift_new.csv"                                                                             
   dbms=csv                                                                                                                             
   replace;                                                                                                                             
run;
