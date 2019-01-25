clear all


cd "/Users/abdullahozturk/Desktop/development/firsthomework"

set more off
gl dta "/Users/abdullahozturk/Desktop/development/firsthomework/dta"
gl out "/Users/abdullahozturk/Desktop/development/firsthomework/out"
gl data2013 "/Users/abdullahozturk/Desktop/development/firsthomework/raw"



use "$data2013/GSEC8_1.dta", clear
keep HHID h8q30a h8q30b h8q31a h8q31b h8q31c h8q36a h8q36b h8q36c h8q36d h8q36e h8q36f h8q36g h8q43 h8q44 h8q44b h8q45a h8q45b h8q45c
foreach var of varlist h8q30a h8q30b h8q31a h8q31b h8q31c h8q36a h8q36b h8q36c h8q36d h8q36e ///
h8q36f h8q36g h8q43 h8q44 h8q44b h8q45a h8q45b h8q45c {
	replace `var' = 0 if `var'==.
}
gen hours_week = h8q36a + h8q36b + h8q36c + h8q36d + h8q36e + h8q36f + h8q36g //hours worked per week
gen hours_year = hours_week*h8q30a*h8q30b 

gen hours_week2 = h8q43
gen hours_year2 = hours_week2 * h8q44 * h8q44b

collapse (sum) hours_week hours_week2 hours_year hours_year2, by(HHID)
 
replace HHID = subinstr(HHID, "H", "", .)
replace HHID = subinstr(HHID, "-", "", .)
destring HHID, gen(hh)
drop HHID
rename hh HHID
 
merge 1:1 HHID using "$out/CIW_final.dta"
drop _merge
 
keep if age> 15 & age < 70
gen intensive = hours_year + hours_year2
bysort urban: egen emp=sum(wgt_X) if intensive>0
bysort urban: egen total=sum(wgt_X) 
gen extensive = emp/total 
 
save "$out/income.dta", replace

/// Part 1 
mean intensive[pw=wgt_X]
mean intensive[pw=wgt_X] if urban==0  
mean intensive[pw=wgt_X] if urban==1  

 
preserve
 
gen log_intensive=log(intensive)
	 
twoway (histogram intensive if urban==0, fcolor(none) lcolor(red)) ///
(histogram intensive if urban==1, fcolor(none) lcolor(blue)), ///
legend(order(1 "R" 2 "U")) xtitle(Intensive margin (hours worked)) graphregion(color(white)) 
graph export "$out/h4.png", replace 
 
restore


foreach var in intensive {
	gen log_`var'=log(`var')
	gen log_`var'_mean=.
	gen v_`var'=.
}

foreach var in intensive {
	sum log_`var' [w=wgt_X]
	replace log_`var'_mean = r(mean)
	replace v_`var'=(log_`var'-log_`var'_mean)^2
}

mean v_intensive [pw=wgt_X]
mean v_intensive [pw=wgt_X] if urban== 0 
mean v_intensive [pw=wgt_X] if urban== 1 

 
 

preserve	  
collapse (mean) intensive v_intensive, by(age)
graph twoway (line intensive age, fcolor(none) lcolor(red)), ///
xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
ylabel(, labsize(medlarge) nogrid) graphregion(color(white))
graph export "$out/figure3.png", replace
	 
graph twoway (line v_intensive age, fcolor(none) lcolor(red)), ///
xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
ylabel(, labsize(medlarge) nogrid) graphregion(color(white))
graph export "$out/figure4.png", replace
	 
restore

 
 
*** GENDER
use "$out/income.dta", clear
 
forvalues i=1/2 {
	mean intensive[pw=wgt_X] if gender==`i'
	mean intensive[pw=wgt_X] if urban==0 & gender==`i'
	mean intensive[pw=wgt_X] if urban==1 & gender==`i'
}	 


 
preserve
 
gen log_intensive = log(intensive)
	 
twoway (histogram log_intensive if urban==0 & gender==1, fcolor(none) lcolor(red)) ///
(histogram log_intensive if urban==1 & gender==1, fcolor(none) lcolor(blue)), ///
legend(order(1 "R" 2 "U")) xtitle("Intensive margin ") graphregion(color(white)) 
graph export "$out/h5.png", replace 

twoway (histogram log_intensive if urban==0 & gender==2, fcolor(none) lcolor(red)) ///
(histogram log_intensive if urban==1 & gender==2, fcolor(none) lcolor(blue)), ///
legend(order(1 "R" 2 "U")) xtitle("Intensive margin") graphregion(color(white)) 
graph export "$out/h6.png", replace 

restore


forvalues i = 1/2 {
	foreach var in intensive {
		gen log_`var'_`i'=log(`var') if gender == `i'
		gen log_`var'_mean_`i'=. if gender == `i'
		gen v_`var'_`i'=. if gender == `i'
	}
}
 
forvalues i = 1/2 {
	foreach var in intensive {
		sum log_`var'_`i' [w=wgt_X] if gender == `i'
		replace log_`var'_mean_`i' = r(mean) if gender == `i'
		replace v_`var'_`i'=(log_`var'_`i'-log_`var'_mean_`i')^2 if gender == `i'
	}
}
 
forvalues i = 1/2 {
	mean v_intensive_`i' [pw=wgt_X]
	mean v_intensive_`i' [pw=wgt_X] if urban== 0 
	mean v_intensive_`i' [pw=wgt_X] if urban== 1 
}

 
 

preserve
collapse (mean) intensive v_intensive_*, by(age gender)
	 	 
graph twoway (line intensive age if gender==1, fcolor(none) lcolor(red)) ///
(line intensive age if gender==2, fcolor(none) lcolor(blue)), ///
xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
ylabel(, labsize(medlarge) nogrid) ytitle("Intensive margin ", size(medlarge)) ///
legend(order(1 "Male" 2 "Female")) graphregion(color(white))
graph export "$out/f7.png", replace
	 
graph twoway (line v_intensive_1 age, fcolor(none) lcolor(red)) ///
(line v_intensive_2 age if gender==2, fcolor(none) lcolor(blue)), ///
xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
ylabel(, labsize(medlarge) nogrid) ytitle("Intensive margin (variance)", size(medlarge)) ///
legend(order(1 "Male" 2 "Female")) graphregion(color(white))
graph export "$out/f8.png", replace
	 
restore

 //// Education Part
use "$out/income.dta", clear
 
drop if education==. | education==99
rename education educ
 
gen education =.
replace education = 1 if educ < 17 // 
replace education = 2 if educ>=17 & educ < 34 
replace education = 3 if educ>=34 

 
forvalues i=1/3 {
	mean intensive[pw=wgt_X] if education==`i'
	mean intensive[pw=wgt_X] if urban==0 & education==`i'
	mean intensive[pw=wgt_X] if urban==1 & education==`i'  
}

 
preserve
 
gen log_intensive=log(intensive)
	 
twoway (histogram log_intensive if urban==0 & education==1, fcolor(none) lcolor(red)) ///
(histogram log_intensive if urban==1 & education==1, fcolor(none) lcolor(blue)), ///
legend(order(1 "R" 2 "U")) xtitle("Intensive margin") graphregion(color(white)) 
graph export "$out/h9.png", replace 

twoway (histogram log_intensive if urban==0 & education==2, fcolor(none) lcolor(red)) ///
(histogram log_intensive if urban==1 & education==2, fcolor(none) lcolor(blue)), ///
legend(order(1 "R" 2 "U")) xtitle("Intensive margin") graphregion(color(white)) 
graph export "$out/h10.png", replace 
	 
twoway (histogram log_intensive if urban==0 & education==3, fcolor(none) lcolor(red)) ///
(histogram log_intensive if urban==1 & education==3, fcolor(none) lcolor(blue)), ///
legend(order(1 "R" 2 "U")) xtitle("Intensive margin") graphregion(color(white)) 
graph export "$out/h11.png", replace 

restore


forvalues i = 1/3 {
	foreach var in intensive {
		gen log_`var'_`i'=log(`var') if education == `i'
		gen log_`var'_mean_`i'=. if education == `i'
		gen v_`var'_`i'=. if education == `i'
	}
}
 
forvalues i = 1/3 {
	foreach var in intensive {
		sum log_`var'_`i' [w=wgt_X] if education == `i'
		replace log_`var'_mean_`i' = r(mean) if education == `i'
		replace v_`var'_`i'=(log_`var'_`i'-log_`var'_mean_`i')^2 if education == `i'
	}
}
 
forvalues i = 1/3 {
	mean v_intensive_`i' [pw=wgt_X] if education==`i'
	mean v_intensive_`i' [pw=wgt_X] if urban== 0 & education==`i'
	mean v_intensive_`i' [pw=wgt_X] if urban== 1 & education==`i'
}

 


preserve
	  
collapse (mean) intensive v_intensive_*, by(age education)
	 	 
graph twoway (line intensive age if education==1, fcolor(none) lcolor(red)) ///
(line intensive age if education==2, fcolor(none) lcolor(blue)) ///
(line intensive age if education==3, fcolor(none) lcolor(black)), ///
xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
ylabel(, labsize(medlarge) nogrid) ytitle("Intensive margin", size(medlarge)) ///
legend(order(1 "No edu" 2 "Less than high school" 3 "High school+")) ///
graphregion(color(white))
graph export "$out/f12.png", replace
	 
graph twoway (line v_intensive_1 age if education==1, fcolor(none) lcolor(red)) ///
(line v_intensive_2 age if education==2, fcolor(none) lcolor(blue)) ///
(line v_intensive_3 age if education==3, fcolor(none) lcolor(black)), ///
xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
ylabel(, labsize(medlarge) nogrid) ytitle("Intensive margin ", size(medlarge)) ///
legend(order(1 "No edu" 2 "Less than high school" 3 "High school+")) ///
graphregion(color(white))
graph export "$out/f13.png", replace
	 
restore
 

 
