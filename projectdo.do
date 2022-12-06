cd "D:\Books, Notes\APU\SEM 3\Data Analysis\Stata Grp project\Women data set"

set maxvar 100000
use "IAIR7DFL.DTA", clear


keep caseid v001 v002 v003 v005 v101 v614 v106 v107 v024 v025 s934 v513 v511 v130 v131 v133 v217 v149 v150 v151 v152 awfactt awfactw awfactu awfactr awfacte v155 v170 v301 v362 v384a v384b v384c v384d v447a v481

** ideal children = v614
** education = v106
** state = v024
** sector = v025
** internet = s934
** duration of marriage = v513
** age at first marriage = v511
** caste = v131
** religion = v130

* creating weights
gen weights = v005/1000000

* encoding education variable 
gen edu = string(v106)
encode edu, gen(_education)

recode _education (1 2 3 = 1 "Educated") (0 = 0 "Not educated"), gen(Educated)

*  generating descriptive stats for ideal number of children and educational attainment
tab v106 
tab v614

* encoding religion variable
gen religion = string(v130)
encode religion, gen(_religion)
recode _religion (1 = 1 "Hindu") (2 3 4 5 6 7 8 9 10 96 = 0 "others"), gen(Hindu)
recode _religion (2= 1 "Muslims") (1 3 4 5 6 7 8 9 10 96 = 0 "others"), gen(Muslim)
recode _religion (3= 1 "Christian") (1 2 4 5 6 7 8 9 10 96 = 0 "others"), gen(Christian)
recode _religion (4= 1 "Sikh") (1 2 3 5 6 7 8 9 10 96 = 0 "others"), gen(Sikh)

* labelling variable
label variable Hindu "Hindu"
label variable Muslim "Muslim"
label variable Christian "Christian"
label variable Sikh "Sikh"

label variable Educated "Educated"



* creating globals of controls
global controls_1 i.Hindu i.Muslim i.Christian i.Sikh i.s934 v513 v511

* running simple ols
* reg v614 v106 $controls_1 

reg v614 Educated $controls_1 [pweight = weights]
outreg2 using "ols1.tex", replace label title("OLS") sdec(2) bdec(2)

* running fixed effects regression
areg v614 Educated $controls_1 [pweight=weights], absorb(v024) vce(cluster v001) 

outreg2 using "FixedEffects_reg.tex", replace label sdec(2) bdec(2) addtext(State FE, Yes) addnote(Standard Errors Clustered at Individual Level) title("Regression with State Fixed Effects")

* Sector wise FE regression

* encoding sector variable
drop sector
gen sector = string(v025)

gen urban = 1 if v025 == 1
replace urban = 0 if v025 !=1

areg v614 Educated $controls_1 i.urban [pweight=weights], absorb(v024) vce(cluster v001)
outreg2 using "FixedEffects_Sector_reg.tex", replace label sdec(2) bdec(2) addtext(State FE, Yes) addnote(Standard Errors Clustered at Individual Level) title("Sector wise Regression with State Fixed Effects")



