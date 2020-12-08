# NLSIG COVID19Lab
A nlogistic-sigmoid modelling laboratory for the COVID-19 pandemic growth

nlogistic-sigmoid function (NLSIG) is a modern logistic-sigmoid function definition for modelling growth (or decay) processes.

## Links
* NLSIG Conference Slides []()
* NLSIG Paper []()



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
 
## Miscellanous
If interested in dedicating the time to port to other languages, 
please contact me.

## License
This work is licensed under the [GNU AGPL](https://github.com/somefunAgba/NLSIG_COVID19Lab/blob/main/LICENSE) 