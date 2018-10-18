Python Analyses - Obesity
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
y_name = "OBESITY"
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
    ## Dependent Variable  :     OBESITY                Number of Observations:         106
    ## Mean dependent var  :      0.3713                Number of Variables   :           9
    ## S.D. dependent var  :      0.0815                Degrees of Freedom    :          97
    ## R-squared           :      0.9386
    ## Adjusted R-squared  :      0.9335
    ## Sum squared residual:       0.043                F-statistic           :    185.3216
    ## Sigma-square        :       0.000                Prob(F-statistic)     :    3.02e-55
    ## S.E. of regression  :       0.021                Log likelihood        :     263.744
    ## Sigma-square ML     :       0.000                Akaike info criterion :    -509.489
    ## S.E of regression ML:      0.0201                Schwarz criterion     :    -485.518
    ## 
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     t-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.2867094       0.0115821      24.7545017       0.0000000
    ##               CDPROP       0.0067670       0.0059714       1.1332354       0.2599087
    ##               DISSIM      -2.4019410       0.2560059      -9.3823647       0.0000000
    ##              POVERTY       0.0669149       0.0378700       1.7669614       0.0803800
    ##             MEDICAID       0.0102097       0.0394411       0.2588586       0.7962928
    ##                 TANF      -0.0289628       0.0939317      -0.3083391       0.7584855
    ##                 SNAP       0.1010419       0.0337061       2.9977352       0.0034546
    ##                 RENT      -0.0820779       0.0138800      -5.9133970       0.0000001
    ##                UNINS       0.3983559       0.0807500       4.9331973       0.0000034
    ## ------------------------------------------------------------------------------------
    ## 
    ## REGRESSION DIAGNOSTICS
    ## MULTICOLLINEARITY CONDITION NUMBER           26.545
    ## 
    ## TEST ON NORMALITY OF ERRORS
    ## TEST                             DF        VALUE           PROB
    ## Jarque-Bera                       2           1.107           0.5748
    ## 
    ## DIAGNOSTICS FOR HETEROSKEDASTICITY
    ## RANDOM COEFFICIENTS
    ## TEST                             DF        VALUE           PROB
    ## Breusch-Pagan test                8          20.629           0.0082
    ## Koenker-Bassett test              8          23.988           0.0023
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Moran's I (error)              0.2289         4.705           0.0000
    ## Lagrange Multiplier (lag)         1          21.887           0.0000
    ## Robust LM (lag)                   1          12.815           0.0003
    ## Lagrange Multiplier (error)       1          14.562           0.0001
    ## Robust LM (error)                 1           5.490           0.0191
    ## Lagrange Multiplier (SARMA)       2          27.377           0.0000
    ## 
    ## ================================ END OF REPORT =====================================

Spatial lag model
indicated

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
    ## Dependent Variable  :     OBESITY                Number of Observations:         106
    ## Mean dependent var  :      0.3713                Number of Variables   :           9
    ## S.D. dependent var  :      0.0815                Degrees of Freedom    :          97
    ## R-squared           :      0.9750
    ## Adjusted R-squared  :      0.9730
    ## Sum squared residual:       0.017                F-statistic           :    473.3753
    ## Sigma-square        :       0.000                Prob(F-statistic)     :   3.781e-74
    ## S.E. of regression  :       0.013                Log likelihood        :     311.429
    ## Sigma-square ML     :       0.000                Akaike info criterion :    -604.858
    ## S.E of regression ML:      0.0128                Schwarz criterion     :    -580.887
    ## 
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     t-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.2398649       0.0061313      39.1213135       0.0000000
    ##               CDPROP       0.0049361       0.0038019       1.2983142       0.1972578
    ##                BLACK       0.1217076       0.0064328      18.9199926       0.0000000
    ##              POVERTY       0.0498442       0.0241821       2.0611993       0.0419597
    ##             MEDICAID       0.0435133       0.0251537       1.7298980       0.0868291
    ##                 TANF      -0.0219028       0.0598986      -0.3656644       0.7154117
    ##                 SNAP       0.0611511       0.0217467       2.8119747       0.0059592
    ##                 RENT      -0.0678283       0.0088288      -7.6826372       0.0000000
    ##                UNINS       0.3076511       0.0520537       5.9102657       0.0000001
    ## ------------------------------------------------------------------------------------
    ## 
    ## REGRESSION DIAGNOSTICS
    ## MULTICOLLINEARITY CONDITION NUMBER           27.552
    ## 
    ## TEST ON NORMALITY OF ERRORS
    ## TEST                             DF        VALUE           PROB
    ## Jarque-Bera                       2          13.109           0.0014
    ## 
    ## DIAGNOSTICS FOR HETEROSKEDASTICITY
    ## RANDOM COEFFICIENTS
    ## TEST                             DF        VALUE           PROB
    ## Breusch-Pagan test                8          24.249           0.0021
    ## Koenker-Bassett test              8          16.267           0.0387
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Moran's I (error)              0.1025         2.432           0.0150
    ## Lagrange Multiplier (lag)         1           0.016           0.8989
    ## Robust LM (lag)                   1           0.117           0.7319
    ## Lagrange Multiplier (error)       1           2.920           0.0875
    ## Robust LM (error)                 1           3.021           0.0822
    ## Lagrange Multiplier (SARMA)       2           3.037           0.2190
    ## 
    ## ================================ END OF REPORT =====================================

``` python
error1 = ps.spreg.GM_Lag(y, x1, w=w, name_y=y_name, name_x=x1_names, spat_diag=True, robust='white', 
    name_w='queens', name_ds='STL_REDLINING_Analysis2.shp')
print(error1.summary)
```

    ## REGRESSION
    ## ----------
    ## SUMMARY OF OUTPUT: SPATIAL TWO STAGE LEAST SQUARES
    ## --------------------------------------------------
    ## Data set            :STL_REDLINING_Analysis2.shp
    ## Weights matrix      :      queens
    ## Dependent Variable  :     OBESITY                Number of Observations:         106
    ## Mean dependent var  :      0.3713                Number of Variables   :          10
    ## S.D. dependent var  :      0.0815                Degrees of Freedom    :          96
    ## Pseudo R-squared    :      0.9510
    ## Spatial Pseudo R-squared:  0.9462
    ## 
    ## White Standard Errors
    ## ------------------------------------------------------------------------------------
    ##             Variable     Coefficient       Std.Error     z-Statistic     Probability
    ## ------------------------------------------------------------------------------------
    ##             CONSTANT       0.2194837       0.0191552      11.4581738       0.0000000
    ##               CDPROP       0.0062062       0.0050175       1.2369091       0.2161208
    ##               DISSIM      -1.8142005       0.2758542      -6.5766654       0.0000000
    ##              POVERTY       0.0786267       0.0356097       2.2080132       0.0272434
    ##             MEDICAID       0.0356388       0.0480872       0.7411290       0.4586152
    ##                 TANF      -0.0205902       0.0654685      -0.3145051       0.7531375
    ##                 SNAP       0.0904753       0.0454365       1.9912489       0.0464535
    ##                 RENT      -0.0735484       0.0153873      -4.7798229       0.0000018
    ##                UNINS       0.2809078       0.0909882       3.0873000       0.0020198
    ##            W_OBESITY       0.2132810       0.0458483       4.6518810       0.0000033
    ## ------------------------------------------------------------------------------------
    ## Instrumented: W_OBESITY
    ## Instruments: W_CDPROP, W_DISSIM, W_MEDICAID, W_POVERTY, W_RENT, W_SNAP,
    ##              W_TANF, W_UNINS
    ## 
    ## DIAGNOSTICS FOR SPATIAL DEPENDENCE
    ## TEST                           MI/DF       VALUE           PROB
    ## Anselin-Kelejian Test             1           3.621          0.0570
    ## ================================ END OF REPORT =====================================
