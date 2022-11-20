/* -------------------------------------------------------------- */
/* SOCIAL ECONOMICS PAPER: ATTITUDES TOWARD CHILDREN NEEDED FOR HAPPINESS   */
/*                                                                */
/* Author: ARIANNA AIMAR, KIMBERLY MASSA, ANDREA VIÑAS */                                    
/* Last update: June 2022 by Andrea Viñas                 */
/* -------------------------------------------------------------- */
********************************************************************************
*** WORKSPACE SET-UP ***
********************************************************************************

	clear all
    version 17
	set more off
	capture program drop _all
	capture log close                                                               
	set seed 1234

/* 
        To run this file on your system:
                Copy Paste the IF HOSTNAME If below, using your own hostname that you might find with the di code below
				Once you add an IF statement with your own hostname, it will work for all users listed.
				 
        
*/


	local hostname "`c(hostname)'"
	di "`c(hostname)'"
	
		
		if "`hostname'" == "DESKTOP-PCANDREA" {
		global dir "C:\Users\Andrea\Documents\BSE\TERM III\SOCIAL ECONOMICS\" 
		
		}	

	cd $dir
	
//* open datasets of interest: jugendl, pl, biobirth*//


use pid syear jl0138 jl0206 jl0216 jl0288 jl0330 jl0341 jl0349 jl0366 jl0369 jl0371 jl0376 using jugendl.dta

duplicates report pid
duplicates drop pid, force
duplicates report pid

merge 1:1 pid using biobirth.dta, keepusing(sex) 
drop if _merge==1 | _merge==2
rename _merge _mergesex
duplicates report pid

merge 1:m pid using pl.dta, keepusing(plh0258_h) 
drop if _merge==1 | _merge==2
rename _merge _mergereligion
duplicates report pid /* we don't drop duplicates here due to deleting needed values */

label language EN

**COMMENTS: for jugendl dataset we are interested in jl0138, jl0206, jl0216, jl0288, jl0330, jl0341, jl0349, jl0366, jl0369, jl0371, jl0376; for biobirth dataset is sex; for pl is plh0258_h. We merge through pid.


//* rename variables *//


rename jl0330 children_happy /* dependent variable */
rename jl0138 private_school
rename jl0206 importance_securejob 
rename jl0216 importance_allowsfamily
rename jl0288 parents_in_HH
rename jl0341 success_training
rename jl0349 ptrait_risk
rename jl0366 ptrait_communicative
rename jl0369 ptrait_oftenworry
rename jl0371 ptrait_procrastination
rename jl0376 ptrait_reserved
rename sex d_sex
rename plh0258_h religion


/* Two dependent variables: Having a Children Opinion & Children Needed For Happiness */

tabulate children_happy
drop if children_happy == -8 | children_happy == -5 | children_happy == -1
label define children_happy 1 "Children Are Necessary for Happiness" 2 "Can Be Just As Happy Without Children" 3 "Can Be Even Happier Without Children" 4 "Undecided, Unkown"
label values children_happy children_happy
tabulate children_happy
**COMMENTS: we match the tags of the dependent variable with the one coming from jungendl.

tabulate children_happy
gen d_children_happy=1
replace d_children_happy=0 if children_happy==4
label define d_children_happy 0 "Not Having Opinion" 1 "Having Opinion"
label values d_children_happy d_children_happy
label variable d_children_happy "Dummy Opinion Children"
tabulate d_children_happy
**COMMENTS: we have generated the dummy dep var for the first part of the two-part model (probit)

gen ordered_children_happy = children_happy if children_happy == 1 | children_happy == 2 | children_happy == 3
label variable ordered_children_happy "Ordered Children Dep Var"
tabulate ordered_children_happy
replace ordered_children_happy=4 if ordered_children_happy==1
tabulate ordered_children_happy
replace ordered_children_happy=1 if ordered_children_happy==3
tabulate ordered_children_happy
replace ordered_children_happy=3 if ordered_children_happy==4
tabulate ordered_children_happy
label define ordered_children_happy 1 "Can Be Even Happier Without Children" 2 "Can Be Just As Happy Without Children" 3 "Children Are Necessary for Happiness"
label values ordered_children_happy ordered_children_happy
tabulate ordered_children_happy
**COMMENTS: We have done now two steps: first, we have generated a new variable which only skips (not drop) the "Unkown, Undecided" opinion. Second, we rearrange the order of the values, as in the second part of the two-part model (oprobit) we are interested about people who moves from "Can Be Even Happier Without Children" to "Children Are Necessary for Happiness"

/* Socioeconomics: Sex, Private School, Religion, Parents in HH */


tabulate d_sex /* correct already */
label variable d_sex "Dummy Sex"

tabulate private_school
drop if private_school == -8 | private_school == -1
gen d_private_school=1
replace d_private_school=0 if private_school==3
tab d_private_school
label variable d_private_school "Dummy Private School Participation"
label define d_private_school 0 "No" 1 "Yes"
label values d_private_school d_private_school
tabulate d_private_school

tabulate religion
label variable religion "Religion (original pl)"
drop if religion == -8 | religion == -5 | religion == -1
tabulate religion
duplicates drop pid, force /* now that we deleted useless answers of religion variable, we drop duplicates of pid */
duplicates report pid
gen d_religion = 1
replace d_religion=0 if religion==6
label variable d_religion "Dummy Religion"
label define d_religion 0 "No" 1 "Yes"
label values d_religion d_religion
tabulate d_religion

tabulate parents_in_HH
label define parents_in_HH 1 "Both parents" 2 "Only father" 3 "Only mother" 4 "None"
label values parents_in_HH parents_in_HH
tabulate parents_in_HH

/* Job Perspective: Importance of High Income, Importance of Secure Job, Training for Success */

tabulate importance_securejob
drop if importance_securejob == -1
label define importance_securejob 1 "Very Important" 2 "Important" 3 "Less Important" 4 "Unimportant"
label values importance_securejob importance_securejob
tabulate importance_securejob

tabulate importance_allowsfamily
drop if importance_allowsfamily == -1
label define importance_allowsfamily 1 "Very Important" 2 "Important" 3 "Less Important" 4 "Unimportant"
label values importance_allowsfamily importance_allowsfamily
tabulate importance_allowsfamily

tabulate success_training
drop if success_training == -1
label define success_training 1 "Very Important" 2 "Important" 3 "Less Important" 4 "Unimportant"
label values success_training success_training
tabulate success_training


/* Personal traits: Communicative, Procrastination, Often worry, Willigness to risks */

tabulate ptrait_communicative
drop if ptrait_communicative== -8 | ptrait_communicative== -1
tabulate ptrait_communicative

tabulate ptrait_procrastination
drop if ptrait_procrastination== -1
tabulate ptrait_procrastination

tabulate ptrait_oftenworry
drop if ptrait_oftenworry== -1
tabulate ptrait_oftenworry

tabulate ptrait_risk
drop if ptrait_risk== -1
label variable ptrait_risk "Willigness to risk"
tabulate ptrait_risk

***********************************************************************
****** TWO-PART MODEL: PROBIT & ORDERED PROBIT MODELS (+MARGINS) ******
***********************************************************************

/* first part: probit with dummy dep variable */

probit d_children_happy d_sex d_private_school d_religion i.parents_in_HH i.importance_securejob ptrait_oftenworry ptrait_procrastination ptrait_reserved ptrait_risk

outreg2 using probit_output_socialecon.tex

/* second part: oprobit with scale dep variable */

oprobit ordered_children_happy d_sex d_private_school d_religion i.parents_in_HH i.importance_allowsfamily i.success_training ptrait_communicative ptrait_procrastination ptrait_oftenworry ptrait_risk

outreg2 using oprobit_output_socialecon.tex

/* margins oprobit */

margins, dydx(*)
outreg2 using oprobitmargins_output_socialecon.tex