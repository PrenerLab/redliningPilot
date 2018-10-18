Python Analyses - Asthma
================
Christopher Prener, Ph.D.
(October 18, 2018)

## Introduction

This notebook…

## Dependencies

``` r
# tidyverse packages
library(ggplot2)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
# other packages
library(reticulate) # python interface
```

``` python
import os
import pysal as ps
```

    ## /Library/Frameworks/Python.framework/Versions/3.6/lib/python3.6/site-packages/pysal/__init__.py:65: VisibleDeprecationWarning: PySAL's API will be changed on 2018-12-31. The last release made with this API is version 1.14.4. A preview of the next API version is provided in the `pysal` 2.0 prelease candidate. The API changes and a guide on how to change imports is provided at https://pysal.org/about
    ##   ), VisibleDeprecationWarning)

``` python
import numpy as np
```

## Calculate Spatial Weights

``` python
w = ps.queen_from_shapefile("../data/spatial/clean/STL_REDLINING_Analysis2.shp", idVariable="GEOID", sparse=False)
w.transform = 'r'
```

## Set up Variables

``` python
db = ps.open("../data/spatial/clean/STL_REDLINING_Analysis2.dbf", 'r')
y_name = "ASTHMA"
y = np.array([db.by_col(y_name)]).T
x_names = ['CDPROP']
x = np.array([db.by_col(var) for var in x_names]).T
xa_names = ['CDPROP', 'DISSIM']
xa = np.array([db.by_col(var) for var in xa_names]).T
xb_names = ['CDPROP', 'DISSIM', 'POVERTY', 'UNINS']
xb = np.array([db.by_col(var) for var in xb_names]).T
x1_names = ['CDPROP','DISSIM', 'POVERTY', 'MEDICAID', 'TANF', 'SNAP', 'RENT', 'UNINS']
x1 = np.array([db.by_col(var) for var in x1_names]).T
x2_names = ['CDPROP','BLACK', 'POVERTY', 'MEDICAID', 'TANF', 'SNAP', 'RENT', 'UNINS']
x2 = np.array([db.by_col(var) for var in x2_names]).T
```

``` python
print(y.shape)
```

    ## (106, 1)

``` python
print(x1.shape)
```

    ## (106, 8)

``` python
print(x2.shape)
```

    ## (106, 8)

## Fit OLS Models

### Main Effect Model

``` python
ols = ps.spreg.OLS(y, x, w=w, name_y=y_name, name_x=x_names, spat_diag=True, moran=True, 
    name_w='queens', name_ds='STL_REDLINING_Analysis2.shp')
print(ols.summary)
```

    ## REGRESSION
    ## ----------
    ## SUMMARY OF OUTPUT: ORDINARY LEAST SQUARES
    ## -----------------------------------------
    ## Data set            :STL_REDLINING_Analysis2.shp
    ## Weights matrix      :      queens
    ## Dependent Variable  :      ASTHMA                Number of Observations:         106
    ## Mean dependent var  :      0.1118                Number of Variables   :           2
    ## S.D. dependent var  :      0.0190                Degrees of Freedom    :         104
    ## R-squared           :      0.1074
    ## Adjusted R-squared  :      0.0988
    ## Sum squared residual:       0.034                F-statistic           :     12.5170
    ## Sigma-square        :       0.000                Prob(F-statistic)     :   0.0006042
    ## S.E. of regression  :       0.018                Log likelihood        :     276.484
    ## Sigma-square ML     :       0.000                Akaike info criterion :    -548.968
    ## S.E of regression ML:      0.0178                Schwarz criterion     :    -543.641
    ## 
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     t-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.1052298       0.0025486      41.2899584       0.0000000
    ##               CDPROP       0.0159199       0.0044998       3.5379376       0.0006042
    ## ------------------------------------------------------------------------------------
    ## 
    ## REGRESSION DIAGNOSTICS
    ## MULTICOLLINEARITY CONDITION NUMBER            2.520
    ## 
    ## TEST ON NORMALITY OF ERRORS
    ## TEST                             DF        VALUE           PROB
    ## Jarque-Bera                       2           5.229           0.0732
    ## 
    ## DIAGNOSTICS FOR HETEROSKEDASTICITY
    ## RANDOM COEFFICIENTS
    ## TEST                             DF        VALUE           PROB
    ## Breusch-Pagan test                1           1.278           0.2584
    ## Koenker-Bassett test              1           2.656           0.1032
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Moran's I (error)              0.6353        11.244           0.0000
    ## Lagrange Multiplier (lag)         1         110.224           0.0000
    ## Robust LM (lag)                   1           0.913           0.3394
    ## Lagrange Multiplier (error)       1         112.227           0.0000
    ## Robust LM (error)                 1           2.916           0.0877
    ## Lagrange Multiplier (SARMA)       2         113.139           0.0000
    ## 
    ## ================================ END OF REPORT =====================================

### Main Effect + Segrgation

``` python
olsa = ps.spreg.OLS(y, xa, w=w, name_y=y_name, name_x=xa_names, spat_diag=True, moran=True, 
    name_w='queens', name_ds='STL_REDLINING_Analysis2.shp')
print(olsa.summary)
```

    ## REGRESSION
    ## ----------
    ## SUMMARY OF OUTPUT: ORDINARY LEAST SQUARES
    ## -----------------------------------------
    ## Data set            :STL_REDLINING_Analysis2.shp
    ## Weights matrix      :      queens
    ## Dependent Variable  :      ASTHMA                Number of Observations:         106
    ## Mean dependent var  :      0.1118                Number of Variables   :           3
    ## S.D. dependent var  :      0.0190                Degrees of Freedom    :         103
    ## R-squared           :      0.7417
    ## Adjusted R-squared  :      0.7367
    ## Sum squared residual:       0.010                F-statistic           :    147.8656
    ## Sigma-square        :       0.000                Prob(F-statistic)     :   5.322e-31
    ## S.E. of regression  :       0.010                Log likelihood        :     342.199
    ## Sigma-square ML     :       0.000                Akaike info criterion :    -678.399
    ## S.E of regression ML:      0.0096                Schwarz criterion     :    -670.409
    ## 
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     t-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.1097319       0.0014065      78.0194541       0.0000000
    ##               CDPROP       0.0049986       0.0025275       1.9776574       0.0506391
    ##               DISSIM      -1.1531631       0.0725135     -15.9027330       0.0000000
    ## ------------------------------------------------------------------------------------
    ## 
    ## REGRESSION DIAGNOSTICS
    ## MULTICOLLINEARITY CONDITION NUMBER            2.654
    ## 
    ## TEST ON NORMALITY OF ERRORS
    ## TEST                             DF        VALUE           PROB
    ## Jarque-Bera                       2           1.963           0.3748
    ## 
    ## DIAGNOSTICS FOR HETEROSKEDASTICITY
    ## RANDOM COEFFICIENTS
    ## TEST                             DF        VALUE           PROB
    ## Breusch-Pagan test                2           1.697           0.4280
    ## Koenker-Bassett test              2           2.401           0.3011
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Moran's I (error)              0.2363         4.553           0.0000
    ## Lagrange Multiplier (lag)         1          13.208           0.0003
    ## Robust LM (lag)                   1           2.570           0.1089
    ## Lagrange Multiplier (error)       1          15.531           0.0001
    ## Robust LM (error)                 1           4.893           0.0270
    ## Lagrange Multiplier (SARMA)       2          18.101           0.0001
    ## 
    ## ================================ END OF REPORT =====================================

### Main Effect + Segregation + Poverty

``` python
olsb = ps.spreg.OLS(y, xb, w=w, name_y=y_name, name_x=xb_names, spat_diag=True, moran=True, 
    name_w='queens', name_ds='STL_REDLINING_Analysis2.shp')
print(olsb.summary)
```

    ## REGRESSION
    ## ----------
    ## SUMMARY OF OUTPUT: ORDINARY LEAST SQUARES
    ## -----------------------------------------
    ## Data set            :STL_REDLINING_Analysis2.shp
    ## Weights matrix      :      queens
    ## Dependent Variable  :      ASTHMA                Number of Observations:         106
    ## Mean dependent var  :      0.1118                Number of Variables   :           5
    ## S.D. dependent var  :      0.0190                Degrees of Freedom    :         101
    ## R-squared           :      0.9389
    ## Adjusted R-squared  :      0.9365
    ## Sum squared residual:       0.002                F-statistic           :    388.3046
    ## Sigma-square        :       0.000                Prob(F-statistic)     :   2.314e-60
    ## S.E. of regression  :       0.005                Log likelihood        :     418.647
    ## Sigma-square ML     :       0.000                Akaike info criterion :    -827.294
    ## S.E of regression ML:      0.0047                Schwarz criterion     :    -813.977
    ## 
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     t-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.0736221       0.0021610      34.0685922       0.0000000
    ##               CDPROP      -0.0004334       0.0013288      -0.3261414       0.7449922
    ##               DISSIM      -0.3755691       0.0558929      -6.7194450       0.0000000
    ##              POVERTY       0.0143708       0.0067598       2.1259080       0.0359488
    ##                UNINS       0.1720483       0.0143357      12.0013508       0.0000000
    ## ------------------------------------------------------------------------------------
    ## 
    ## REGRESSION DIAGNOSTICS
    ## MULTICOLLINEARITY CONDITION NUMBER           15.418
    ## 
    ## TEST ON NORMALITY OF ERRORS
    ## TEST                             DF        VALUE           PROB
    ## Jarque-Bera                       2           2.464           0.2917
    ## 
    ## DIAGNOSTICS FOR HETEROSKEDASTICITY
    ## RANDOM COEFFICIENTS
    ## TEST                             DF        VALUE           PROB
    ## Breusch-Pagan test                4          14.803           0.0051
    ## Koenker-Bassett test              4          14.726           0.0053
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Moran's I (error)              0.2209         4.410           0.0000
    ## Lagrange Multiplier (lag)         1           5.394           0.0202
    ## Robust LM (lag)                   1           1.292           0.2556
    ## Lagrange Multiplier (error)       1          13.569           0.0002
    ## Robust LM (error)                 1           9.467           0.0021
    ## Lagrange Multiplier (SARMA)       2          14.861           0.0006
    ## 
    ## ================================ END OF REPORT =====================================

### Full OLS

``` python
ols1 = ps.spreg.OLS(y, x1, w=w, name_y=y_name, name_x=x1_names, spat_diag=True, moran=True, 
    name_w='queens', name_ds='STL_REDLINING_Analysis2.shp')
print(ols1.summary)
```

    ## REGRESSION
    ## ----------
    ## SUMMARY OF OUTPUT: ORDINARY LEAST SQUARES
    ## -----------------------------------------
    ## Data set            :STL_REDLINING_Analysis2.shp
    ## Weights matrix      :      queens
    ## Dependent Variable  :      ASTHMA                Number of Observations:         106
    ## Mean dependent var  :      0.1118                Number of Variables   :           9
    ## S.D. dependent var  :      0.0190                Degrees of Freedom    :          97
    ## R-squared           :      0.9506
    ## Adjusted R-squared  :      0.9465
    ## Sum squared residual:       0.002                F-statistic           :    233.1287
    ## Sigma-square        :       0.000                Prob(F-statistic)     :   8.493e-60
    ## S.E. of regression  :       0.004                Log likelihood        :     429.833
    ## Sigma-square ML     :       0.000                Akaike info criterion :    -841.666
    ## S.E of regression ML:      0.0042                Schwarz criterion     :    -817.695
    ## 
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     t-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.0778779       0.0024171      32.2189642       0.0000000
    ##               CDPROP      -0.0005347       0.0012462      -0.4290782       0.6688178
    ##               DISSIM      -0.3246837       0.0534275      -6.0770896       0.0000000
    ##              POVERTY       0.0166920       0.0079033       2.1120238       0.0372535
    ##             MEDICAID      -0.0087020       0.0082312      -1.0571938       0.2930490
    ##                 TANF      -0.0135178       0.0196032      -0.6895721       0.4921097
    ##                 SNAP       0.0304900       0.0070343       4.3344583       0.0000357
    ##                 RENT      -0.0054334       0.0028967      -1.8757154       0.0637017
    ##                UNINS       0.1326626       0.0168522       7.8721026       0.0000000
    ## ------------------------------------------------------------------------------------
    ## 
    ## REGRESSION DIAGNOSTICS
    ## MULTICOLLINEARITY CONDITION NUMBER           26.545
    ## 
    ## TEST ON NORMALITY OF ERRORS
    ## TEST                             DF        VALUE           PROB
    ## Jarque-Bera                       2           0.136           0.9342
    ## 
    ## DIAGNOSTICS FOR HETEROSKEDASTICITY
    ## RANDOM COEFFICIENTS
    ## TEST                             DF        VALUE           PROB
    ## Breusch-Pagan test                8          36.170           0.0000
    ## Koenker-Bassett test              8          39.639           0.0000
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Moran's I (error)              0.1937         4.069           0.0000
    ## Lagrange Multiplier (lag)         1           5.330           0.0210
    ## Robust LM (lag)                   1           1.861           0.1725
    ## Lagrange Multiplier (error)       1          10.435           0.0012
    ## Robust LM (error)                 1           6.966           0.0083
    ## Lagrange Multiplier (SARMA)       2          12.296           0.0021
    ## 
    ## ================================ END OF REPORT =====================================

Spatial error model indicated - mixed evidence for spatial lag so not
run.

``` python
ols2 = ps.spreg.OLS(y, x2, w=w, name_y=y_name, name_x=x2_names, spat_diag=True, moran=True, 
    name_w='queens', name_ds='STL_REDLINING_Analysis2.shp')
print(ols2.summary)
```

    ## REGRESSION
    ## ----------
    ## SUMMARY OF OUTPUT: ORDINARY LEAST SQUARES
    ## -----------------------------------------
    ## Data set            :STL_REDLINING_Analysis2.shp
    ## Weights matrix      :      queens
    ## Dependent Variable  :      ASTHMA                Number of Observations:         106
    ## Mean dependent var  :      0.1118                Number of Variables   :           9
    ## S.D. dependent var  :      0.0190                Degrees of Freedom    :          97
    ## R-squared           :      0.9664
    ## Adjusted R-squared  :      0.9636
    ## Sum squared residual:       0.001                F-statistic           :    348.7963
    ## Sigma-square        :       0.000                Prob(F-statistic)     :   6.486e-68
    ## S.E. of regression  :       0.004                Log likelihood        :     450.311
    ## Sigma-square ML     :       0.000                Akaike info criterion :    -882.621
    ## S.E of regression ML:      0.0035                Schwarz criterion     :    -858.650
    ## 
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     t-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.0716566       0.0016540      43.3227976       0.0000000
    ##               CDPROP      -0.0007705       0.0010256      -0.7512072       0.4543466
    ##                BLACK       0.0173617       0.0017353      10.0048059       0.0000000
    ##              POVERTY       0.0141890       0.0065235       2.1750511       0.0320570
    ##             MEDICAID      -0.0040581       0.0067856      -0.5980444       0.5512041
    ##                 TANF      -0.0122755       0.0161586      -0.7596885       0.4492832
    ##                 SNAP       0.0242380       0.0058665       4.1315878       0.0000765
    ##                 RENT      -0.0034749       0.0023817      -1.4589790       0.1478016
    ##                UNINS       0.1185782       0.0140423       8.4443668       0.0000000
    ## ------------------------------------------------------------------------------------
    ## 
    ## REGRESSION DIAGNOSTICS
    ## MULTICOLLINEARITY CONDITION NUMBER           27.552
    ## 
    ## TEST ON NORMALITY OF ERRORS
    ## TEST                             DF        VALUE           PROB
    ## Jarque-Bera                       2          19.371           0.0001
    ## 
    ## DIAGNOSTICS FOR HETEROSKEDASTICITY
    ## RANDOM COEFFICIENTS
    ## TEST                             DF        VALUE           PROB
    ## Breusch-Pagan test                8          78.729           0.0000
    ## Koenker-Bassett test              8          40.217           0.0000
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Moran's I (error)              0.0327         1.170           0.2421
    ## Lagrange Multiplier (lag)         1           1.738           0.1874
    ## Robust LM (lag)                   1           2.417           0.1200
    ## Lagrange Multiplier (error)       1           0.298           0.5853
    ## Robust LM (error)                 1           0.976           0.3231
    ## Lagrange Multiplier (SARMA)       2           2.715           0.2574
    ## 
    ## ================================ END OF REPORT =====================================

Worse fit and no spatial autocorrelation in model fit with
`BLACK`.

### Spatial Error Model

``` python
error1 = ps.spreg.GM_Error_Het(y, x1, w=w, name_y=y_name, name_x=x1_names, name_w='queens', name_ds='STL_REDLINING_Analysis2.shp')
print(error1.summary)
```

    ## REGRESSION
    ## ----------
    ## SUMMARY OF OUTPUT: SPATIALLY WEIGHTED LEAST SQUARES (HET)
    ## ---------------------------------------------------------
    ## Data set            :STL_REDLINING_Analysis2.shp
    ## Weights matrix      :      queens
    ## Dependent Variable  :      ASTHMA                Number of Observations:         106
    ## Mean dependent var  :      0.1118                Number of Variables   :           9
    ## S.D. dependent var  :      0.0190                Degrees of Freedom    :          97
    ## Pseudo R-squared    :      0.9497
    ## N. of iterations    :           1                Step1c computed       :          No
    ## 
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     z-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.0776973       0.0027753      27.9957137       0.0000000
    ##               CDPROP      -0.0005291       0.0013898      -0.3806940       0.7034303
    ##               DISSIM      -0.2915393       0.0565689      -5.1537010       0.0000003
    ##              POVERTY       0.0164894       0.0081449       2.0244927       0.0429195
    ##             MEDICAID      -0.0036758       0.0088456      -0.4155460       0.6777423
    ##                 TANF      -0.0128896       0.0165606      -0.7783285       0.4363754
    ##                 SNAP       0.0256629       0.0066736       3.8454230       0.0001203
    ##                 RENT      -0.0070871       0.0032361      -2.1900410       0.0285213
    ##                UNINS       0.1388706       0.0225910       6.1471629       0.0000000
    ##               lambda       0.4465757       0.1090997       4.0932819       0.0000425
    ## ------------------------------------------------------------------------------------
    ## ================================ END OF REPORT =====================================
