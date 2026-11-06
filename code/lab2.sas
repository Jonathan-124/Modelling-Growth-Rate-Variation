/* Setting path and library */
libname growth "/home/u64435675/sasuser.v94/Labs";

/* Reading in the data*/
data growthcc;
set growth.growthcc;
run;

data growthax;
set growth.growthax;
run;

data growth2;
set growth.growth2;
run;

/* Refactoring sex, adding transformed age, then clean up datasets*/
data growth_cleaned;
    set growthcc; /* CHANGE HERE to look at models for the other datasets */
    age2 = (age - 11) / 3;
    if sex = 1 then gender = "M";
    else gender = "F";
    agec = age; /* Assigning as categorical for REPEATED statement later */
    age2c = age2; /* Assigning as categorical for REPEATED statement later */
run;

/* Visualizing the data*/
proc sgpanel data = growth_cleaned;
panelby gender / columns = 2;
series x = age y = measure / group = indiv markers ;
/* To change title based on dataset*/
title 'Age vs. Growth (Dataset CC)';
run;

/* Fitting the model (untransformed age)*/
proc mixed data = growth_cleaned; /* add NOBOUND option here */ 
class idnr indiv sex gender agec age2c;
model measure = age gender age*gender/ solution chisq OUTP = pred outpm = ave;
random intercept age / type=un subject=idnr G Gcorr;
repeated agec / subject=idnr R Rcorr;
run;

/* Visualizing the predictions*/
proc sort data = pred;
by age;
run;

proc sgplot data = ave;
series y = pred x = age / group = gender;
run;

proc sgpanel data = pred;
panelby gender;
series y = pred x = age / GROUP = indiv;
run;

/* Fitting the model (transformed age)*/
proc mixed data = growth_cleaned; /* add NOBOUND option here */ 
class idnr indiv sex gender agec age2c;
model measure = age2 gender age2*gender/ solution chisq OUTP = pred outpm = ave;
random intercept age2 / type=un subject=idnr G Gcorr;
repeated age2c / subject=idnr R Rcorr;
run;

/* Visualizing the predictions*/
proc sort data = pred;
by age2;
run;

proc sgplot data = ave;
series y = pred x = age2 / group = gender;
run;

proc sgpanel data = pred;
panelby gender;
series y = pred x = age2 / GROUP = indiv;
run;

/* Fitting random-int only model to AR(1) variance-covariance matrix (untransformed age)*/
proc mixed data = growth_cleaned;
class idnr indiv sex gender agec age2c;
model measure = age2 gender age2*gender/ solution chisq OUTP = pred outpm = ave;
random intercept / type=un subject=idnr G Gcorr;
repeated age2c /type=AR(1) subject=idnr R Rcorr;
run;

/* Fitting random-int only model to AR(1) + measurement error variance-covariance matrix (untransformed age)*/
proc mixed data = growth_cleaned;
class idnr indiv sex gender agec age2c;
model measure = age2 gender age2*gender/ solution chisq OUTP = pred outpm = ave;
random intercept / type=un subject=idnr G Gcorr;
repeated age2c /type=AR(1) local subject=idnr R Rcorr; /* LOCAL adds measurement error component */
run;
