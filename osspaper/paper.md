---
title: 'NLSIG COVID19Lab: A modern logistic-growth tool (nlogistic-sigmoid) for modelling the dynamics of the COVID-19 pandemic process'
tags:
  - Matlab
  - COVID-19
  - logistic function
  - machine learning
  - neural networks
  - optimization
  - regression
  - epidemiology
authors:
  - name: Oluwasegun A. Somefun^[Corresponding author.]
    orcid: 0000-0002-5171-8026
    affiliation: 1
  - name: Kayode F. Akingbade
    affiliation: 1
  - name: Folasade M. Dahunsi
    affiliation: 1
affiliations:
 - name: Federal University of Technology Akure
   index: 1
date: 15 December 2020
bibliography: paper.bib


# Summary

The growth (flow or trend) dynamics in any direction for many natural phenomena such as epidemic spreads, population growths, 
adoption of new ideas can be approximately modelled by the logistic-sigmoid curve [@taylorForecastingScale2018]. 
The scientific basis for this prevalence is given in [@bejanConstructalLawOrigin2011]. 
Such growth-processes can be viewed as complex input--output systems that involve 
multiple peak inflection phases withrespect to time. This is an idea that 
can be traced back in the crudest sense to [@reedSummationLogisticCurves1927]. 
In particular, the logistic-sigmoid function with time-varying parameters 
is the core trend model in Facebook's Prophet model for time-series growth-forecasting 
at scale [@taylorForecastingScale2018] on big data. Consequently, we introduce a `NLSIG-COVID19Lab`, 
a software pakage that illustrates the power of modelling 
the COVID-19 pandemic with the nlogistic-sigmoid function (`NLSIG`), which is a modern neural-network definition for the logistic-sigmoid function. 

`NLSIG-COVID19Lab` is a nlogistic-sigmoid playground for modelling the COVID-19 pandemic growth. It is useful as a quick real-time monitoring tool for the COVID-19 pandemic, and, 
was designed to be used by humans, both researchers and non-reserachers. This work won the best paper at the **2nd African Symposium on Big Data, Analytics and Machine Intelligence and 6th TYAN International Thematic Workshop December 3-4, 2020**.

# Statement of need

Admittedly, epidemiological models such as the SEIRD variants 
[@leeEstimationCOVID19Spread2020;@okabeMathematicalModelEpidemics2020] are just another form of representing sigmoidal growth [@xsRichardsModelRevisited2012]. It has been noted in 
[@christopoulosNovelApproachEstimating2020] that the SEIRD-variant models yield largely 
exaggerated forecasts on the final cumulative growth number. This can also be said of the results 
of various application of logistic modelling as regards the current state of the COVID-19 pandemic 
which have largely resulted in erroneous identification of the epidemic's progress and its future projection [@matthewWhyModelingSpread2020;@batistaEstimationStateCorona2020;@wuGeneralizedLogisticGrowth2020], hence leading policymakers astray. 

Notably, two recurring limitations of the logistic definitions in the literature and other software packages exist, 
a trend that has continued since the first logistic-sigmoid function introduction. First is that, 
the support interval (co-domain) of logistic-sigmoids is assumed to be infinite, this assumption 
violates the critical natural principle of finite growth. Second, estimation of the hyper-parameters 
for the individual logistic-sigmoids that make the multiple logistic-sigmoid sum is computed separately, 
instead of as a unified function. The effect of this, is that, as the number of logistic-sigmoids 
considered in the sum increases, regression analysis becomes more cumbersome and complicated as can be observed in these works [@leeEstimationCOVID19Spread2020;@batistaEstimationStateCorona2020;
@hsiehRealtimeForecastMultiphase2006;@wuGeneralizedLogisticGrowth2020;
@chowellNovelSubepidemicModeling2019;@taylorForecastingScale2018]. 
These limitations are efficiently overcome by the nlogistic-sigmoid function for the logistic-sigmoid curve.

The development of `NLSIG-COVID19Lab` was motivated largely by research needs to illustrate the power of the nlogistic-sigmoid neural pipeline. 

Notably, instead of engaging in false prophecy or predictions of the cumulative growth of an ongoing growth phenomena, whose source is both uncertain and complex to be encoded in current mathematical models [@christopoulosEfficientIdentificationInflection2016;@matthewWhyModelingSpread2020] on the contrary, for the logistic curve we instead make projections by means of:

- two metrics for robust projective measurements of the modelled time-evolution of a growth-process in an area or locale of interest. 
- adapt the DKW inequality for the KS test for constructing a confidence interval of uncertainty on the model given by the nlogistic-sigmoid curve. 


The UI (both scripts and graphical) for the `NLSIG-COVID19Lab` package was designed to provide a user-friendly interface for modelling the time-series
growth of the COVID-19 epidemic through the `NLSIG` by using official datasets. `NLSIG-COVID19Lab` is currently written in MATLAB but will be extended to other languages in the future. 
 

# Core Data Source
World Health Organization

<!-- # Mathematics

Single dollars ($) are required for inline mathematics e.g. $f(x) = e^{\pi/x]$

Double dollars make self-standing equations:

$$\Theta(x) = \left\{\begin{array]{l]
0\textrm{ if ] x < 0\cr
1\textrm{ else]
\end{array]\right.$$

You can also use plain \LaTeX for equations
\begin{equation]\label{eq:fourier]
\hat f(\omega) = \int_{-\infty]^{\infty] f(x) e^{i\omega x] dx
\end{equation]
and refer to \autoref{eq:fourier] from text.
 -->
<!-- # Citations

Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

If you want to cite a software repository URL (e.g. something on GitHub without a preferred
citation) then you can do it with the example BibTeX entry below for @fidgit.

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)" -->

<!-- # Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example]](figure.png)
and referenced from text using \autoref{fig:example].

Figure sizes can be customized by adding an optional second parameter:
![Caption for example figure.](figure.png){ width=20% ] -->

<!-- # Acknowledgements

We acknowledge contributions from Brigitta Sipocz, Syrtis Major, and Semyeong
Oh, and support from Kathryn Johnston during the genesis of this project. -->

# References