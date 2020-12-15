---
title: '`NLSIG-COVID19Lab`: A modern logistic-growth tool (nlogistic-sigmoid) for modelling the dynamics of the COVID-19 pandemic process'
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
---

# Summary

The growth (flow or trend) dynamics in any direction for many natural phenomena such as epidemic spreads, population growths, 
adoption of new ideas can be approximately modelled by the logistic-sigmoid curve [@taylorForecastingScale2018]. 
In particular, the logistic-sigmoid function with time-varying parameters is the core trend 
model in Facebook's Prophet model for time-series growth-forecasting 
at scale [@taylorForecastingScale2018] on big data. 
The scientific basis for this prevalence is given in [@bejanConstructalLawOrigin2011]. 
Such growth-processes can be viewed as complex input--output systems that involve 
multiple peak inflection phases with respect to time. An idea that 
can be traced back in the crudest sense to [@reedSummationLogisticCurves1927]. 

A unified, modern logistic-sigmoid function definition which considers restricted growth from 
a two-dimensional perspective is the nlogistic-sigmoid function 
[@somefunLogisticsigmoidNlogisticsigmoidModelling2020] (`NLSIG`) or logistic neural-network (`LNN`) pipeline. 
In this context, `NLSIG-COVID19Lab` functions as a `NLSIG` playground for modelling 
of the COVID-19 epidemic growth in each affected country of the world and the world as a whole. 


# Statement of need

Admittedly, epidemiological models such as the SEIRD variants 
[@leeEstimationCOVID19Spread2020;@okabeMathematicalModelEpidemics2020] are just another form of representing sigmoidal growth [@xsRichardsModelRevisited2012]. It has been noted in 
[@christopoulosNovelApproachEstimating2020] that the SEIRD-variant models yield largely exaggerated forecasts on the final cumulative growth number. This can also be said of the results 
of various application of logistic modelling as regards the current state of the COVID-19 pandemic [@batistaEstimationStateCorona2020;@wuGeneralizedLogisticGrowth2020]
which have largely resulted in erroneous identification of the epidemic's progress and its future projection , hence leading policymakers astray [@matthewWhyModelingSpread2020]. 

Notably, two recurring limitations of the logistic definitions in the literature and other software packages exist. A trend that has continued since the first logistic-sigmoid function introduction. First is that, the co-domain of logistic function is assumed to be infinite. This assumption violates the natural principle of finite growth. Second, estimation of the hyper-parameters  for the individual logistic-sigmoids that make the multiple logistic-sigmoid sum is computed separately, instead of as a unified function. The effect of this, is that, as the number of logistic-sigmoids 
considered in the sum increases, regression analysis becomes more cumbersome and complicated as can be observed in these works [@leeEstimationCOVID19Spread2020;@batistaEstimationStateCorona2020;
@hsiehRealtimeForecastMultiphase2006;@wuGeneralizedLogisticGrowth2020;
@chowellNovelSubepidemicModeling2019;@taylorForecastingScale2018]. 
These limitations are efficiently overcome by the nlogistic-sigmoid function (or logistic neural-network pipeline) `NLSIG` for describing logistic growth.


The `NLSIG` is a logistic neural-network machine-learning tool under active development. The logistic growth benefits are:

 - retains functional simplicity
	
 - unified function definition
	
 - improved nonlinear modelling power
	
	
The development of the `NLSIG-COVID19Lab` was motivated largely by research needs to illustrate the power of the nlogistic-sigmoid neural pipeline. 

Notably, instead of engaging in false prophecy or predictions of the cumulative growth of an ongoing growth phenomena, whose source is both uncertain and complex to be encoded in current mathematical models [@christopoulosEfficientIdentificationInflection2016;@matthewWhyModelingSpread2020] on the contrary, in this software package we instead make projections by means of:

- two metrics for robust projective measurements of the modelled time-evolution of a growth-process in an area or locale of interest. 

- adaptation of the Dvoretzky–Kiefer–Wolfowitz (DKW) inequality for the Kolmogorov–Smirnov (KS) test to construct a confidence interval of uncertainty on the nlogistic-sigmoid model with a 99% (1-0.01) probability. 

`NLSIG-COVID19Lab` is useful as a quick real-time monitoring tool for the COVID-19 pandemic. It was designed to be used by humans, both researchers and non-reserachers. 

The application of the `NLSIG` to modelling the COVID-19 pandemic won the best paper at the *2nd African Symposium on Big Data, Analytics and Machine Intelligence and 6th TYAN International Thematic Workshop, December 3-4, 2020*.

`NLSIG-COVID19Lab` is currently written in MATLAB but will be implemented in other languages in the future. 
 
The UIfor the `NLSIG-COVID19Lab` (both scripts and graphical interface) for was designed to provide a user-friendly interface for the `NLSIG`modelling the time-series growth of the COVID-19 pandemic from official datasets. 

### Core Data Source
As at the time of writing. The COVID-19 Database of `NLSIG-COVID19Lab` is sourced from the:

* World Health Organization

* Center for Systems Science and Engineering at the Johns Hopkins University.


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

<!-- # Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example]](figure.png)
and referenced from text using \autoref{fig:example].

Figure sizes can be customized by adding an optional second parameter:
![Caption for example figure.](figure.png){ width=20% ] -->

# Acknowledgements

This work received no funding. 

# References