Python Analyses - Dental
================
Christopher Prener, Ph.D.
(October 17, 2018)

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
y_name = "DENTAL"
y = np.array([db.by_col(y_name)]).T
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
    ## Dependent Variable  :      DENTAL                Number of Observations:         106
    ## Mean dependent var  :      0.4936                Number of Variables   :           9
    ## S.D. dependent var  :      0.1341                Degrees of Freedom    :          97
    ## R-squared           :      0.9676
    ## Adjusted R-squared  :      0.9649
    ## Sum squared residual:       0.061                F-statistic           :    361.9691
    ## Sigma-square        :       0.001                Prob(F-statistic)     :   1.144e-68
    ## S.E. of regression  :       0.025                Log likelihood        :     244.823
    ## Sigma-square ML     :       0.001                Akaike info criterion :    -471.645
    ## S.E of regression ML:      0.0240                Schwarz criterion     :    -447.675
    ## 
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     t-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.7901264       0.0138456      57.0669171       0.0000000
    ##               CDPROP      -0.0000525       0.0071384      -0.0073582       0.9941442
    ##               DISSIM       1.3374156       0.3060373       4.3701066       0.0000312
    ##              POVERTY      -0.0214631       0.0452710      -0.4741022       0.6364925
    ##             MEDICAID       0.0160751       0.0471491       0.3409417       0.7338848
    ##                 TANF       0.0312304       0.1122888       0.2781255       0.7815080
    ##                 SNAP      -0.1673951       0.0402933      -4.1544172       0.0000703
    ##                 RENT       0.0061026       0.0165926       0.3677887       0.7138321
    ##                UNINS      -1.2548320       0.0965311     -12.9992561       0.0000000
    ## ------------------------------------------------------------------------------------
    ## 
    ## REGRESSION DIAGNOSTICS
    ## MULTICOLLINEARITY CONDITION NUMBER           26.545
    ## 
    ## TEST ON NORMALITY OF ERRORS
    ## TEST                             DF        VALUE           PROB
    ## Jarque-Bera                       2           4.304           0.1162
    ## 
    ## DIAGNOSTICS FOR HETEROSKEDASTICITY
    ## RANDOM COEFFICIENTS
    ## TEST                             DF        VALUE           PROB
    ## Breusch-Pagan test                8          10.229           0.2493
    ## Koenker-Bassett test              8           9.148           0.3300
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Moran's I (error)             -0.0124         0.336           0.7366
    ## Lagrange Multiplier (lag)         1           8.736           0.0031
    ## Robust LM (lag)                   1           9.704           0.0018
    ## Lagrange Multiplier (error)       1           0.043           0.8358
    ## Robust LM (error)                 1           1.011           0.3146
    ## Lagrange Multiplier (SARMA)       2           9.747           0.0076
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
    ## Dependent Variable  :      DENTAL                Number of Observations:         106
    ## Mean dependent var  :      0.4936                Number of Variables   :           9
    ## S.D. dependent var  :      0.1341                Degrees of Freedom    :          97
    ## R-squared           :      0.9736
    ## Adjusted R-squared  :      0.9715
    ## Sum squared residual:       0.050                F-statistic           :    447.7786
    ## Sigma-square        :       0.001                Prob(F-statistic)     :   5.208e-73
    ## S.E. of regression  :       0.023                Log likelihood        :     255.768
    ## Sigma-square ML     :       0.000                Akaike info criterion :    -493.535
    ## S.E of regression ML:      0.0217                Schwarz criterion     :    -469.565
    ## 
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     t-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.8155056       0.0103658      78.6724058       0.0000000
    ##               CDPROP       0.0008924       0.0064277       0.1388308       0.8898716
    ##                BLACK      -0.0735429       0.0108755      -6.7622687       0.0000000
    ##              POVERTY      -0.0107167       0.0408833      -0.2621293       0.7937776
    ##             MEDICAID      -0.0033704       0.0425258      -0.0792559       0.9369924
    ##                 TANF       0.0254711       0.1012669       0.2515240       0.8019411
    ##                 SNAP      -0.1397256       0.0367658      -3.8004213       0.0002522
    ##                 RENT      -0.0020370       0.0149263      -0.1364726       0.8917305
    ##                UNINS      -1.1927529       0.0880041     -13.5533822       0.0000000
    ## ------------------------------------------------------------------------------------
    ## 
    ## REGRESSION DIAGNOSTICS
    ## MULTICOLLINEARITY CONDITION NUMBER           27.552
    ## 
    ## TEST ON NORMALITY OF ERRORS
    ## TEST                             DF        VALUE           PROB
    ## Jarque-Bera                       2           1.473           0.4787
    ## 
    ## DIAGNOSTICS FOR HETEROSKEDASTICITY
    ## RANDOM COEFFICIENTS
    ## TEST                             DF        VALUE           PROB
    ## Breusch-Pagan test                8           9.463           0.3047
    ## Koenker-Bassett test              8           8.929           0.3483
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Moran's I (error)             -0.0863         0.985           0.3248
    ## Lagrange Multiplier (lag)         1           1.014           0.3141
    ## Robust LM (lag)                   1           2.065           0.1507
    ## Lagrange Multiplier (error)       1           2.073           0.1499
    ## Robust LM (error)                 1           3.124           0.0771
    ## Lagrange Multiplier (SARMA)       2           4.138           0.1263
    ## 
    ## ================================ END OF REPORT =====================================

Worse fit and no spatial autocorrelation in model fit with
`BLACK`.

``` python
lag1 = ps.spreg.GM_Lag(y, x1, w=w, name_y=y_name, name_x=x1_names, spat_diag=True, robust='white', 
    name_w='queens', name_ds='STL_REDLINING_Analysis2.shp')
print(lag1.summary)
```

    ## REGRESSION
    ## ----------
    ## SUMMARY OF OUTPUT: SPATIAL TWO STAGE LEAST SQUARES
    ## --------------------------------------------------
    ## Data set            :STL_REDLINING_Analysis2.shp
    ## Weights matrix      :      queens
    ## Dependent Variable  :      DENTAL                Number of Observations:         106
    ## Mean dependent var  :      0.4936                Number of Variables   :          10
    ## S.D. dependent var  :      0.1341                Degrees of Freedom    :          96
    ## Pseudo R-squared    :      0.9703
    ## Spatial Pseudo R-squared:  0.9706
    ## 
    ## White Standard Errors
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     z-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.7097356       0.0298604      23.7684472       0.0000000
    ##               CDPROP       0.0005148       0.0066848       0.0770083       0.9386169
    ##               DISSIM       0.8286724       0.2882717       2.8746232       0.0040451
    ##              POVERTY      -0.0252284       0.0377552      -0.6682100       0.5039995
    ##             MEDICAID      -0.0091388       0.0448116      -0.2039375       0.8384023
    ##                 TANF       0.0248635       0.1161060       0.2141448       0.8304341
    ##                 SNAP      -0.1634068       0.0350638      -4.6602674       0.0000032
    ##                 RENT       0.0037091       0.0149077       0.2488069       0.8035102
    ##                UNINS      -1.1328289       0.0827728     -13.6860096       0.0000000
    ##             W_DENTAL       0.1291355       0.0427882       3.0180149       0.0025444
    ## ------------------------------------------------------------------------------------
    ## Instrumented: W_DENTAL
    ## Instruments: W_CDPROP, W_DISSIM, W_MEDICAID, W_POVERTY, W_RENT, W_SNAP,
    ##              W_TANF, W_UNINS
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Anselin-Kelejian Test             1           1.158          0.2819
    ## ================================ END OF REPORT =====================================
