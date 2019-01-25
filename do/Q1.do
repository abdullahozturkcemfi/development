cd "/Users/abdullahozturk/Desktop/development/firsthomework"
set more off

gl dta "/Users/abdullahozturk/Desktop/development/firsthomework/dta"
gl out "/Users/abdullahozturk/Desktop/development/firsthomework/out"
gl data2013 "/Users/abdullahozturk/Desktop/development/firsthomework/raw"

use "$out/CIW_final.dta", clear
foreach var in C W I {
	replace `var' = `var'/3696.24
}
 

mean C[pw=wgt_X] if urban==0 
mean C[pw=wgt_X] if urban==1 
mean I [pw=wgt_X] if urban==0 
mean I [pw=wgt_X] if urban==1   
mean W [pw=wgt_X] if urban==0 
mean W [pw=wgt_X] if urban==1 

** Taking outlier out some cleaning
_pctile C, nq(100)
drop if C >r(r99) 
_pctile W, nq(100)
drop if W >r(r99) 
_pctile I, nq(100)
drop if I >r(r99) 

twoway (histogram C if urban==0, fcolor(none) lcolor(red))(histogram C if urban==1, ///
fcolor(none) lcolor(blue)), legend(order(1 "R" 2 "U")) xtitle(Consumption) graphregion(color(white)) 
graph export "$out/h1.png", replace 
 
twoway (histogram I if urban==0, fcolor(none) lcolor(red))(histogram I if urban==1, ///
 fcolor(none) lcolor(blue)),legend(order(1 "R" 2 "U")) xtitle(Income) graphregion(color(white)) 
graph export "$out/h2.png", replace 

twoway (histogram W if urban==0, fcolor(none) lcolor(red))(histogram W if urban==1, ///
fcolor(none) lcolor(blue)),legend(order(1 "R" 2 "U")) xtitle(Wealth) graphregion(color(white)) 
graph export "$out/h3.png", replace 
 

foreach var in C W I {
	gen log_`var' = log(`var')
	gen log_`var'_mean = .
	gen v_`var' = .
}
foreach var in C W I {
	sum log_`var' [w=wgt_X]
	replace log_`var'_mean = r(mean)
	replace v_`var'= (log_`var'-log_`var'_mean)^2
	mean v_`var' [pw=wgt_X] if urban==0
	mean v_`var' [pw=wgt_X] if urban==1
}
mean v_C [pw=wgt_X] if urban== 0 
mean v_C [pw=wgt_X] if urban== 1 
mean v_I [pw=wgt_X] if urban== 0 
mean v_I [pw=wgt_X] if urban== 1 
mean v_W [pw=wgt_X] if urban== 0 
mean v_W [pw=wgt_X] if urban== 1 
drop log_* v_*
 

correlate C I W 
correlate C I W if urban==0 
correlate C I W if urban==1 
 
* Part 4 is left

keep if age<70 
gen I_lc = .
gen W_lc = .
gen C_lc = .
foreach var in I W C {
	forvalues i=15(1)105 {
		sum `var' [w=wgt_X] if age==`i'
		replace `var'_lc = r(mean) if age==`i'
	}
}

preserve
collapse (mean) I_lc W_lc C_lc, by(age) 	 
graph twoway (line I_lc age, fcolor(none) lcolor(purple))(line W_lc age, fcolor(none) /// 
lcolor(blue))(line C_lc age, fcolor(none) lcolor(red)),legend(order(1 "I" 2 "W" 3 "C")) ///
xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
ylabel(, labsize(medlarge) nogrid) graphregion(color(white))
graph export "$out/lifecycle1.png", replace 
restore

** CIW inequality over the lifecycle

foreach var in C W I {
	gen log_`var'=log(`var')
	gen log_`var'_mean=.
	gen v_`var'=.
	gen v_`var'_all =.
}
foreach var in C W I {
	forvalues i=15(1)70{
		sum log_`var' [w=wgt_X] if age==`i'
		replace log_`var'_mean = r(mean) if age==`i'
		replace v_`var' = (log_`var' - log_`var'_mean)^2 if age==`i'
		sum v_`var' [w=wgt_X] if age==`i'
		replace v_`var'_all = r(mean) if age==`i'
	}
}
foreach var in C W I {
	forvalues i=15(1)70 {
		sum v_`var' [w=wgt_X] if age==`i'
		replace v_`var'_all = r(mean) if age==`i'
	}
}
preserve
collapse (mean) v_*, by(age) 
graph twoway (line v_I_all age, fcolor(none) lcolor(purple))(line v_W_all age, fcolor(none) ///
lcolor(blue))(line v_C_all age, fcolor(none) lcolor(red)),legend(order(1 "Var log(I)" 2 "Var log(W)" 3 "Var log(C)")) ///
xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
ylabel(, labsize(medlarge) nogrid) graphregion(color(white))
graph export "$out/lifecycle2.png", replace
restore 
 
* Part 5

use "$out/CIW_final.dta", clear

foreach var in C W I {
	replace `var' = `var'/3696.24
}
sort I
preserve
sort I
gen cum_I_C = C[1]
replace cum_I_C = C[_n]+cum_I_C[_n-1] if _n>1
sum cum_I_C, d
scalar list
restore
preserve
sort I
gen cum_I_W = W[1]
replace cum_I_W = W[_n]+cum_I_W[_n-1] if _n>1
sum cum_I_W, d
scalar list
restore
 
