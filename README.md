# NLSIG COVID19Lab

[![View NLSIG_COVID19Lab on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/84043-nlsig_covid19lab)

A nlogistic-sigmoid modelling laboratory for the COVID-19 pandemic growth

<img alt="NLSIG_COVID19LAB" src="https://github.com/somefunAgba/NLSIG_COVID19Lab/blob/main/nlsig_avatar.png"/>

nlogistic-sigmoid function (NLSIG) is a modern logistic-sigmoid function definition for modelling growth (or decay) processes. It features two logistic metrics (YIR and XIR) for monitoring growth from a two-dimensional (x-y axis) perspective.

## Links
* [NLSIG Conference Presentation Slides](https://github.com/somefunAgba/NLSIG_COVID19Lab/blob/main/nlsigcv19_confslide.pdf) *Best Student Paper* at the **2nd African Symposium on Big Data, Analytics and Machine Intelligence and 6th TYAN International Thematic Workshop December 3-4, 2020**.
 
* [NLSIG Preprint](https://arxiv.org/abs/2008.04210)

## Data Source
World Health Organization

## Getting Started : MATLAB

1. Run 'su.m' to add all the project folders and files to MATLAB's path
   or type ``su`` in the command window

2. Open the 'ui' folder to see possible user interaction with the lab's api.

	You should see:
	'view_ccode.m'

	'upd_all.m'

	'query_single.m'

	'query_batch.m'

	'query_all.m'

	First, it is recommended to start with 'query_single.m'. 
	The country code for the world here is ``WD``.

	### 'view_ccode.m'
	View all country codes.
	Example: type ``view_ccode`` in the command window.

	### 'upd_all.m'
	Update data on the COVID-19 pandemic for all country codes. This needs
	a good internet connection.
	Example: type ``upd_all`` in the command window.

	### 'query_single.m'
	Query COVID-19 pandemic for selected country code.

	### 'query_batch.m'
	Query COVID-19 pandemic for a batch of selected country codes.

	### 'query_all.m'
	Query COVID-19 pandemic for all country codes.



3.	To view saved model fit results and logistic 		metrics for infections and deaths. 
	Open the 'assets' folder and 'measures' folder

	### 'assets' folder
	Stores all graphics for the model fit of infections and deaths in a folder 
	named by the last date time-stamp in the data. 
	Graphics are individually saved using the country code. 

	For example: 'WDi.pdf' and 'WDd.pdf' indicates the
	COVID-19 infections and deaths model fit graphics for the World 
	to the last date time-stamp in the data.

	### 'measures' folder
	Stores all estimated logistic metrics for infections and deaths till 
	the last date time-stamp in the data in the 'infs' and 'dths' 
	subfolders respectively.
	
	
## Showcase
Running 'query_single.m' with the search_code as ``WD``
gave the following model fit for the ongoing COVID-19 pandemic as at 6th December 2020.

#### Infections
<p align="center">
 <img alt="WDi" src="https://github.com/somefunAgba/NLSIG_COVID19Lab/blob/main/landingWDi.png"/>
</p>
#### Deaths
<p align="center">
<img alt="WDd" src="https://github.com/somefunAgba/NLSIG_COVID19Lab/blob/main/landingWDd.png"/>
</p>

<!--#### Recovered-->

*Metrics Interpretation*: For infections: the YIR = 0.4916 [0.4908, 0.5063] indicates that the numbers are peaking and may start to decrease soon; the XIR = 0.9843 [0.9826, 1.0146] indicates that this time is most likely a peak period. For deaths: the YIR = 0.4584 [0.4241, 0.5079] indicates that the numbers are still increasing but may likely peak soon; the XIR = 0.9266 [0.8634, 1.0245] indicates that this time may most likely be a peak period but could also be a pre-peak period.	
 
## Miscellanous
If interested in dedicating the time to port to other languages, 
please contact me.

## License
This work is licensed under the [GNU AGPL](https://github.com/somefunAgba/NLSIG_COVID19Lab/blob/main/LICENSE) 

## Citation Details
*Author*: Oluwasegun Somefun, Kayode F. Akingbade and Folasade M. Dahunsi

*Title*: On the nlogistic-sigmoid modelling for complex growth processes: in application to the COVID-19 pandemic

*Conference*: 2nd African Symposium on Big Data, Analytics and Machine Intelligence and 6th TYAN International Thematic Workshop on Data Science for Solution-driven and Sustainable Response to current developing world challenges.

*Date*: December 3, 2020

