DATA PROCESSING
 1. script importProcessData.m prepares the final matrix "R".
 2. MATLAB and PostgreSQL must be connected via ODBC connection
REGRESSION LEARNER APP (by MATLAB)
 1. Use "R" as input for the Regression Learner App in MATLAB
 2. Column 1 is the dependent variable, the rest 300 are the independent variables (predictors).
 4. k-fold cross validation is set to 5 (k=5)
 5. If you do not have access to the Regression Learner App in MATLAB, I have included the auto-generated code by MATLAB for every model used.
