

clear all
set more off
	
  global main "/Users/abdullahozturk/Desktop/DevelopmentHW3/"
  
  global dofiles "${main}do/" 
  global data "${main}dta/"
  global out "${main}out/" 



use "${data}dataUGA.dta", clear
 
 keep hh year wave lnc lninctotal_trans age age_sq familysize ethnic female urban
 
 bysort year hh: gen dup = _N 
 replace year = 2010 if wave=="2010-2011" & year==2011 & dup==2
 drop dup
 
 bysort year hh: gen dup = _N 
 replace year = 2009 if wave=="2009-2010" & year==2010 & dup==2
 drop dup wave 	
 
 
 reg lninctotal_trans age age_sq familysize i.ethnic i.female i.year i.urban
 predict res
 rename res res_inc
 rename lninctotal_trans income
 
 
 reg lnc age age_sq familysize i.ethnic i.female i.year i.urban
 predict res
 rename res res_c
 
 
 bysort year: egen agg_c = sum(lnc)
 
 keep res_c res_inc agg_c hh year income
 xtset hh year
 
 reshape wide res_c res_inc agg_c income, i(hh) j(year)
 
 forvalues a = 10(1)14 {
	egen agg_c20`a'_t = mean(agg_c20`a')
	drop agg_c20`a'
	rename agg_c20`a'_t agg_c20`a'
 }
 egen agg_c2009_t = mean(agg_c2009)
 drop agg_c2009
 rename agg_c2009_t agg_c2009
 
 reshape long res_c res_inc agg_c income, i(hh)
 rename _j year
 
 bysort hh: ipolate res_c year, generate(res_ci) epolate
 bysort hh: ipolate res_inc year, generate(res_inci) epolate  
 bysort hh: ipolate income year, generate(income_i) epolate  
 
 gen inc_dummy = 1
 replace inc_dummy = 0 if res_ci ==.
 egen numyears = sum(inc_dummy), by(hh)
 drop if numyears <= 1
 drop res_c res_inc inc_dummy numyears

 sort hh year
 egen id = group(hh) 
 
 generate beta = .
 generate phi = .
 
 forvalues i = 1(1)2895 {
	reg d.res_ci d.res_inci d.agg_c if id==`i', nocons
	replace beta = _b[d.res_inci] if id==`i'
	replace phi = _b[d.agg_c] if id==`i'
 }

 reg d.res_ci d.res_inci d.agg_c, nocons
 display _b[d.res_inci]
 display _b[d.agg_c]
 
 preserve
	 collapse beta phi, by(hh)
	 
	 drop if beta > 2
	 drop if beta < -2
	 
	 sum beta, detail
	 
	 histogram beta, title("Figure I:  Beta For Each HH Agg", color(red))  ///
	 xtitle ("Beta") graphregion(color(white)) bcolor(yellow)
	 graph export "${out}histogram_beta.png", replace
 restore
 
 preserve
 	 collapse beta phi, by(hh)

	 drop if phi > 0.00002
	 drop if phi < -0.00002

	 sum phi, detail
	 
	 histogram phi, title("Figure II: Phi For Each HH Agg", color(red)) ///
	 xtitle ("Phi") graphregion(color(white)) bcolor(yellow)
	 graph export "${out}histogram_phi.png", replace
 restore

 
 gen inc_dummy = 1
 replace inc_dummy = 0 if income_i ==.
 egen numyears = sum(inc_dummy), by(hh)
 drop if numyears <= 1
 drop inc_dummy numyears income
 
 collapse (mean) income_i beta, by(hh)

 sort income_i
 gen aggn = _N 
 gen nforhh = _n 
 
 gen inc_group = 0
 replace inc_group = 1 if nforhh<=576
 replace inc_group = 2 if nforhh>576 & nforhh<=1152
 replace inc_group = 3 if nforhh>1152 & nforhh<=1728
 replace inc_group = 4 if nforhh>1728 & nforhh<=2304
 replace inc_group = 5 if nforhh>2304 & nforhh<=2879
 
 forvalues i = 1(1)5 {
	sum beta if inc_group==`i', detail
 }
 drop nforhh
 

 sort beta
 gen nforhh = _n 
 
 gen beta_group = 0
 replace beta_group = 1 if nforhh<=576
 replace beta_group = 2 if nforhh>576 & nforhh<=1152
 replace beta_group = 3 if nforhh>1152 & nforhh<=1728
 replace beta_group = 4 if nforhh>1728 & nforhh<=2304
 replace beta_group = 5 if nforhh>2304 & nforhh<=2879
 
 forvalues i = 1(1)5 {
	sum income_i if beta_group==`i', detail
 }


 
// Run This After You Run the Code Above - Urban Rural Part  Question 4 


clear all
set more off
	
	
  global main "/Users/abdullahozturk/Desktop/DevelopmentHW3/"
  
  global dofiles "${main}do/" 
  global data "${main}dta/"
  global out "${main}out/" 



use "${data}dataUGA.dta", clear
 keep hh year wave lnc lninctotal_trans age age_sq familysize ethnic female urban
 
bysort year hh: gen dup = _N 
 replace year = 2010 if wave=="2010-2011" & year==2011 & dup==2
 drop dup
 
 bysort year hh: gen dup = _N 
 replace year = 2009 if wave=="2009-2010" & year==2010 & dup==2
 drop dup wave 	

	keep if urban==1
	
	
	 reg lninctotal_trans age age_sq familysize i.ethnic i.female i.year
	 predict res
	 rename res res_inc
	 rename lninctotal_trans income
	 
	 reg lnc age age_sq familysize i.ethnic i.female i.year
	 predict res
	 rename res res_c
	 
	
	 
	 bysort year: egen agg_c = sum(lnc)
	 
	 keep res_c res_inc agg_c hh year income
	 xtset hh year
	 
	 reshape wide res_c res_inc agg_c income, i(hh) j(year)
	 
	 forvalues a = 10(1)14 {
		egen agg_c20`a'_t = mean(agg_c20`a')
		drop agg_c20`a'
		rename agg_c20`a'_t agg_c20`a'
	 }
	 egen agg_c2009_t = mean(agg_c2009)
	 drop agg_c2009
	 rename agg_c2009_t agg_c2009
	 
	 reshape long res_c res_inc agg_c income, i(hh)
	 rename _j year
	 
	 bysort hh: ipolate res_c year, generate(res_ci) epolate
	 bysort hh: ipolate res_inc year, generate(res_inci) epolate  
	 bysort hh: ipolate income year, generate(income_i) epolate  
	 
	 gen dummy_income = 1
	 replace dummy_income = 0 if res_ci ==.
	 egen numyears = sum(dummy_income), by(hh)
	 drop if numyears <= 1
	 drop res_c res_inc dummy_income numyears

	 sort hh year
	 egen id = group(hh) 
	 
	 generate beta = .
	 generate phi = .
	 
	 forvalues i = 1(1)615 {
		reg d.res_ci d.res_inci d.agg_c if id==`i', nocons
		replace beta = _b[d.res_inci] if id==`i'
		replace phi = _b[d.agg_c] if id==`i'
	 }

	 reg d.res_ci d.res_inci d.agg_c, nocons
	 display _b[d.res_inci]
	 display _b[d.agg_c]
	 
	 preserve
		 collapse beta phi, by(hh)
		 
		 drop if beta > 2
		 drop if beta < -2
		 
		 sum beta, detail
		 
		 histogram beta, title("Figure III: Beta for Each HHs Urban", color(red)) ///
		 xtitle ("Beta") graphregion(color(white)) bcolor(yellow)
		 graph export "${out}histogram_beta_urban.png", replace
	 restore
	 
	 preserve
		 collapse beta phi, by(hh)

		 drop if phi > 0.00002
		 drop if phi < -0.00002

		 sum phi, detail
		
		 histogram phi, title("Figure IV: Phi For Each HH Urban", color(red)) ///
		 xtitle ("Phi") graphregion(color(white)) bcolor(yellow)
		 graph export "${out}histogram_phi_urban.png", replace
	 restore

	
	 
	 gen dummy_income = 1
	 replace dummy_income = 0 if income_i ==.
	 egen numyears = sum(dummy_income), by(hh)
	 drop if numyears <= 1
	 drop dummy_income numyears income
	 
	 collapse (mean) income_i beta, by(hh)
	 

	 sort income_i
	 gen nagg = _N 
	 gen nforeachhh = _n 
	 
	 gen inc_group = 0
	 replace inc_group = 1 if nforeachhh<=122
	 replace inc_group = 2 if nforeachhh>122 & nforeachhh<=244
	 replace inc_group = 3 if nforeachhh>244 & nforeachhh<=365
	 replace inc_group = 4 if nforeachhh>365 & nforeachhh<=487
	 replace inc_group = 5 if nforeachhh>487 & nforeachhh<=609
	 
	 forvalues i = 1(1)5 {
		sum beta if inc_group==`i', detail
	 }
	 drop nforeachhh
	
	 sort beta
	 gen nforeachhh = _n 

	 gen beta_group = 0
	 replace beta_group = 1 if nforeachhh<=122
	 replace beta_group = 2 if nforeachhh>122 & nforeachhh<=244
	 replace beta_group = 3 if nforeachhh>244 & nforeachhh<=365
	 replace beta_group = 4 if nforeachhh>365 & nforeachhh<=487
	 replace beta_group = 5 if nforeachhh>487 & nforeachhh<=609
	 
	 forvalues i = 1(1)5 {
		sum income_i if beta_group==`i', detail
	 }
 

 

 
 ******* Rural Part
 clear all
set more off
	
  global main "/Users/abdullahozturk/Desktop/DevelopmentHW3/"
  
  global dofiles "${main}do/" 
  global data "${main}dta/"
  global out "${main}out/" 



use "${data}dataUGA.dta", clear
 
 bysort year hh: gen dup = _N 
 replace year = 2010 if wave=="2010-2011" & year==2011 & dup==2
 drop dup
 
 bysort year hh: gen dup = _N 
 replace year = 2009 if wave=="2009-2010" & year==2010 & dup==2
 drop dup wave 	
 
 keep if urban==0
	 
	
	 reg lninctotal_trans age age_sq familysize i.ethnic i.female i.year
	 predict res
	 rename res res_inc
	 rename lninctotal_trans income
	
	
	 reg lnc age age_sq familysize i.ethnic i.female i.year
	 predict res
	 rename res res_c
	 
	
	 
	 bysort year: egen agg_c = sum(lnc)
	 
	 keep res_c res_inc agg_c hh year income
	 xtset hh year
	 
	 reshape wide res_c res_inc agg_c income, i(hh) j(year)
	 
	 forvalues a = 10(1)14 {
		egen agg_c20`a'_t = mean(agg_c20`a')
		drop agg_c20`a'
		rename agg_c20`a'_t agg_c20`a'
	 }
	 egen agg_c2009_t = mean(agg_c2009)
	 drop agg_c2009
	 rename agg_c2009_t agg_c2009
	 
	 reshape long res_c res_inc agg_c income, i(hh)
	 rename _j year
	 
	 bysort hh: ipolate res_c year, generate(res_ci) epolate
	 bysort hh: ipolate res_inc year, generate(res_inci) epolate  
	 bysort hh: ipolate income year, generate(income_i) epolate  
	 
	 gen dummy_income = 1
	 replace dummy_income = 0 if res_ci ==.
	 egen numyears = sum(dummy_income), by(hh)
	 drop if numyears <= 1
	 drop res_c res_inc dummy_income numyears

	 sort hh year
	 egen id = group(hh) 
	 
	 generate beta = .
	 generate phi = .
	 
	 forvalues i = 1(1)2239 {
		reg d.res_ci d.res_inci d.agg_c if id==`i', nocons
		replace beta = _b[d.res_inci] if id==`i'
		replace phi = _b[d.agg_c] if id==`i'
	 }

	 reg d.res_ci d.res_inci d.agg_c, nocons
	 display _b[d.res_inci]
	 display _b[d.agg_c]
	 
	 preserve
		 collapse beta phi, by(hh)
		 
		 drop if beta > 2
		 drop if beta < -2
		 
		 sum beta, detail
		 
		 histogram beta, title("Figure V: Beta For Each HH", color(red)) ///
		 xtitle ("Beta") graphregion(color(white)) bcolor(yellow)
		 graph export "${out}histogram_beta_rural.png", replace
	 restore
	 
	 preserve
		 collapse beta phi, by(hh)

		 drop if phi > 0.00002
		 drop if phi < -0.00002

		 sum phi, detail
		 
		 histogram phi, title("Figure VI: Phi For Each HH", color(red)) ///
		 xtitle ("Phi") graphregion(color(white)) bcolor(yellow) 
		 graph export "${out}histogram_phi_rural.png", replace
	 restore

	
	 
	 gen dummy_income = 1
	 replace dummy_income = 0 if income_i ==.
	 egen numyears = sum(dummy_income), by(hh)
	 drop if numyears <= 1
	 drop dummy_income numyears income
	 
	 collapse (mean) income_i beta, by(hh)
	 
	
	 sort income_i
	 gen nagg = _N 
	 gen nforeachhh = _n
	 
	 gen inc_group = 0
	 replace inc_group = 1 if nforeachhh<=445
	 replace inc_group = 2 if nforeachhh>445 & nforeachhh<=890
	 replace inc_group = 3 if nforeachhh>890 & nforeachhh<=1335
	 replace inc_group = 4 if nforeachhh>1335 & nforeachhh<=1780
	 replace inc_group = 5 if nforeachhh>1780 & nforeachhh<=2226
	 
	 forvalues i = 1(1)5 {
		sum beta if inc_group==`i', detail
	 }
	 drop nforeachhh
	 
	
	 sort beta
	 gen nforeachhh = _n 
	 
	 gen beta_group = 0
	 replace beta_group = 1 if nforeachhh<=445
	 replace beta_group = 2 if nforeachhh>445 & nforeachhh<=890
	 replace beta_group = 3 if nforeachhh>890 & nforeachhh<=1335
	 replace beta_group = 4 if nforeachhh>1335 & nforeachhh<=1780
	 replace beta_group = 5 if nhh>1780 & nhh<=2226
	 
	 forvalues i = 1(1)5 {
		sum income_i if beta_group==`i', detail
	 }
	 
 
