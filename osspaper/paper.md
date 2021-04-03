---
title: '`NLSIG-COVID19Lab`: A modern logistic-growth tool (nlogistic-sigmoid) for descriptively modelling the dynamics of the COVID-19 pandemic process'
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
 - name: Federal University of Technology Akure, Nigeria
   index: 1
date: 15 December 2020
bibliography: paper.bib
---

# Summary

The growth (flow or trend) dynamics in any direction for most natural phenomena such as: epidemic spreads, population growths, 
adoption of new ideas, and many more, can be approximately modelled by the logistic-sigmoid curve. 
In particular, the logistic-sigmoid function with time-varying parameters is the core trend 
model in Facebook's Prophet model for time-series growth-forecasting 
at scale [@taylorForecastingScale2018] on big data. 
The scientific basis for this prevalence is given in [@bejanConstructalLawOrigin2011]. 
Such growth-processes can be viewed as complex input--output systems that involve 
multiple peak inflection phases with respect to time, an idea that 
can be traced back in the crudest sense to [@reedSummationLogisticCurves1927]. A modern definition for the logistic-sigmoid growth which considers restricted growth from  a two-dimensional perspective is the nlogistic-sigmoid function (`NLSIG`) [@somefunLogisticsigmoidNlogisticsigmoidModelling2020] 
or logistic neural-network (`LNN`) pipeline. 

In this context, `NLSIG-COVID19Lab` functions as a `NLSIG` playground for a descriptive modelling 
of the COVID-19 epidemic growth in each affected country of the world and the world as a whole. 


# Statement of need

Epidemiological models such as the SEIRD variants 
[@leeEstimationCOVID19Spread2020;@okabeMathematicalModelEpidemics2020] are just another form of representing sigmoidal growth [@xsRichardsModelRevisited2012]. However, it has been noted 
[@christopoulosNovelApproachEstimating2020] that the SEIRD-variant models yield largely exaggerated forecasts. 
Observing the current state of the COVID-19 pandemic, this is concern is borne out, in 
the results of various applications of logistic modelling [@batistaEstimationStateCorona2020;@wuGeneralizedLogisticGrowth2020]
which have largely led to erroneous assessments of the epidemic's progress and its future projection, leading policymakers astray [@matthewWhyModelingSpread2020]. 

Notably, two recurring limitations of the logistic definitions in the literature and other software packages exist. These two limitations are trends that have persisted since the first introduction of the logistic-sigmoid function [@bacaerVerhulstLogisticEquation2011]. 

First is that, the co-domain of logistic function is assumed to be infinite. This assumption violates the natural principle of finite growth. 
Second is that, during optimization, estimation of the logistic hyper-parameters  for the individual logistic-sigmoids that make the multiple logistic-sigmoid sum is computed separately, instead of as a unified function. The effect of this, is that, as the number of logistic-sigmoids 
considered in the sum increases, regression analysis becomes more cumbersome and complicated as can be observed in a number of works [@leeEstimationCOVID19Spread2020;@batistaEstimationStateCorona2020;
@hsiehRealtimeForecastMultiphase2006;@wuGeneralizedLogisticGrowth2020;
@chowellNovelSubepidemicModeling2019;@taylorForecastingScale2018]. 

These limitations are efficiently overcome by the nlogistic-sigmoid function `NLSIG` (or logistic neural-network pipeline) for describing logistic growth. We note that the `NLSIG` is a logistic neural-network machine-learning tool under active development. The benefits it provides at a functional level are:
	
 - unified function definition,
 
 - functional simplicity and efficient computation,
	
 - improved nonlinear modelling power.
		
Ultimately, the development of the `NLSIG-COVID19Lab` was motivated by research needs, in that it 
illustrates the power of the nlogistic-sigmoid neural pipeline. \linebreak `NLSIG-COVID19Lab` provides an optimization workflow with functions to make modelling and monitoring the COVID-19 pandemic easier and reliable. Notably, instead of engaging in false prophecy 
or predictions on the cumulative growth of an ongoing growth phenomena, whose source is both uncertain and 
complex to encode in current mathematical models [@christopoulosEfficientIdentificationInflection2016;@matthewWhyModelingSpread2020], this software package makes projections by means of:

- two-dimensional perspective metrics: Y-to-Inflection Ratio (YIR, here Y = Infections or Deaths); X-to-Inflection Ratio (XIR, here X = Time in Days) for robust monitoring of the growth-process being modelled in an area or locale of interest. 

- adaptation of the Dvoretzky–Kiefer–Wolfowitz (DKW) inequality for the Kolmogorov–Smirnov (KS) test to construct a non-parametric confidence interval of uncertainty on the nlogistic-sigmoid model with a 99% probability ($\alpha=0.01$) by default. 

`NLSIG-COVID19Lab` is useful as a quick real-time monitoring tool for the COVID-19 pandemic. It was designed to be used by humans: both researchers and non-researchers. 

`NLSIG-COVID19Lab` is currently written in MATLAB but will be implemented in other programming languages in the future. 
 
The user-client end (both user application scripts and graphical user interface) of the `NLSIG-COVID19Lab` 
is designed to provide a friendly interface demonstrating the `NLSIG` modelling power for time-series growth processes from data. 
In this case, the growth-process is the time-series COVID-19 pandemic growth from official datasets (see \autoref{fig:iwdcigui} and \autoref{fig:dwdcigui}).

![GUI Layout showing the Total COVID-19 Infections in the World. \label{fig:iwdcigui}](inf_wd_ci_gui.png){ width=70% } 

![GUI Layout showing the Total COVID-19 Deaths in the World. \label{fig:dwdcigui}](dth_wd_ci_gui.png){ width=70% } 


### Core Data Source
At the time of writing, the COVID-19 database of `NLSIG-COVID19Lab` is sourced from the:

* World Health Organization

* Johns Hopkins University Center for Systems Science and Engineering


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

# Related research and software

To the best of our knowledge, we are unaware of any other software packages or tool providing a similar purpose or functionality for describing the logistic growth of the COVID-19 pandemic from a realistic finite two-dimensional perspective of natural growth.

This application of the `NLSIG` to modelling the COVID-19 pandemic was selected as the best paper at the *2nd African Symposium on Big Data, Analytics and Machine Intelligence and 6th TYAN International Thematic Workshop, December 3-4, 2020*.


# Acknowledgements

This work received no funding. 

# References
