*Mingsong Chen
*May 15, 2022

clear
cd "C:\Users\shira\Documents\Sp22\EC206\Project\Stata"

**************************************************************************
*2011 with update data
{
clear

*import excel Data.xlsx, firstrow
import delimited using govdat3908.csv
drop if quarter<1947
gen qdate = q(1947q1)+_n-1
format qdate %tq
tsset qdate
*Time Variables    
gen t = _n
gen t2 = t^2
gen t3 = t^3


gen rwbus = nwbus/pbus

merge 1:1 qdate using update
keep if _merge==3
drop _merge

local varlist = "rgdp rcons rcnd rcsv rcdur rcndsv rinv rinvfx rnri rres tothours tothoursces rgov rdef"
*Per-capita log variables
foreach var of local varlist {
  gen l`var' = log(`var'/pop)
}
*Log variables
local varlist = "totpop rwbus cpi pgdp"

foreach var of local varlist {
  gen l`var' = log(`var')

}

save project_updated, replace


* VARS THAT USE STANDARD IDENTIFICATION METHOD;
var lg ly lrcndsv lrinvfx ltothoursces lrwbus taxy unemp, lags(1/4) exog(t t2)
varirf create irfgov_3, step(20) bs rep(500) set(irfgov_3, replace)
varirf table oirf, impulse(lg) response(lg ly lrcndsv lrinvfx ltothoursces lrwbus taxy unemp) std
*******************************************************
*Normalizing the IRF Shocks
use irfgov_3.irf, clear
sort irfname impulse response step
sum oirf if impulse=="lg" & response=="lg"
scalar mm = r(max)
gen max = mm
replace oirf=oirf*(1/max)
replace stdoirf = stdoirf*(1/max)
gen u90 = oirf  + 1.645* stdoirf
gen d90 = oirf  - 1.645* stdoirf
save irfgov_3.irf,replace

use project_updated, clear

* VARS THAT USE SHOCKS TO RAMEY-SHAPIRO MILITARY DATES;
var newsy lg ly lrcndsv lrinvfx ltothoursces lrwbus taxy unemp, lags(1/4) exog(t t2)
varirf create irfwar_3, step(20) bs rep(500) set(irfwar_3, replace)
varirf table oirf, impulse(newsy) response(lg ly lrcndsv lrinvfx ltothoursces lrwbus taxy unemp) std
*******************************************************
*Normalizing the IRF Shocks
use irfwar_3.irf, clear
sort irfname impulse response step
sum oirf if impulse=="newsy" & response=="newsy"
scalar mm = r(max)
gen max = mm
replace oirf=oirf*(1/max)
replace stdoirf = stdoirf*(1/max)
gen u90 = oirf  + 1.645* stdoirf
gen d90 = oirf  - 1.645* stdoirf
save irfwar_3.irf,replace

***************************************************************
*IRF Generation
*
*Standard VAR
use irfgov_3.irf, clear
twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "lg", legend(off) xlabel(0 (5) 20)  title("Government Spending", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lg_gov, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "ly", legend(off) xlabel(0 (5) 20)  title("GDP", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename ly_gov, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "lrcndsv", legend(off) xlabel(0 (5) 20)  title("Consumption, ndur + serv", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrcndsv_gov, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "lrinvfx", legend(off) xlabel(0 (5) 20)  title("Investment, nonres + res", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrinvfx_gov, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "ltothoursces", legend(off) xlabel(0 (5) 20)  title("Total Hours", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename ltothoursces_gov, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "lrwbus", legend(off) xlabel(0 (5) 20)  title("Real Wages", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrwbus_gov, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "taxy", legend(off) xlabel(0 (5) 20)  title("Tax Rates", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename taxy_gov, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "unemp", legend(off) xlabel(0 (5) 20)  title("Unemployment Rate", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename unemp_gov, replace


*Military News
use irfwar_3.irf, clear
twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "lg", legend(off) xlabel(0 (5) 20)  title("Government Spending", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lg_war, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "ly", legend(off) xlabel(0 (5) 20)  title("GDP", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename ly_war, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "lrcndsv", legend(off) xlabel(0 (5) 20)  title("Consumption, ndur + serv", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrcndsv_war, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "lrinvfx", legend(off) xlabel(0 (5) 20)  title("Investment, nonres + res", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrinvfx_war, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "ltothoursces", legend(off) xlabel(0 (5) 20)  title("Total Hours", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename ltothoursces_war, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "lrwbus", legend(off) xlabel(0 (5) 20)  title("Real Wages", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrwbus_war, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "taxy", legend(off) xlabel(0 (5) 20)  title("Tax Rates", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename taxy_war, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "unemp", legend(off) xlabel(0 (5) 20)  title("Unemployment Rate", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename unemp_war, replace

*Standard 
gr combine lg_gov ly_gov ltothoursces_gov lrcndsv_gov lrinvfx_gov lrwbus_gov taxy_gov unemp_gov, ///
graphregion(color(white)) plotregion(color(white))

*Military
gr combine lg_war ly_war ltothoursces_war lrcndsv_war lrinvfx_war lrwbus_war taxy_war unemp_war, ///
graphregion(color(white)) plotregion(color(white))

*Together 1
gr combine lg_gov lg_war ly_gov ly_war ltothoursces_gov ltothoursces_war lrcndsv_gov lrcndsv_war , ///
graphregion(color(white)) plotregion(color(white)) colf r(4) c(2)

gr combine lg_gov lg_war, ///
graphregion(color(white)) plotregion(color(white))

gr combine ly_gov ly_war, ///
graphregion(color(white)) plotregion(color(white))

gr combine ltothoursces_gov ltothoursces_war, ///
graphregion(color(white)) plotregion(color(white))

gr combine lrcndsv_gov lrcndsv_war, ///
graphregion(color(white)) plotregion(color(white))

gr combine linvfx_gov linfx_war, ///
graphregion(color(white)) plotregion(color(white))

gr combine lrinvfx_gov lrinvfx_war lrwbus_gov lrwbus_war taxy_gov taxy_war unemp_gov unemp_war, ///
graphregion(color(white)) plotregion(color(white))


graph export "Standard.png", as(png) name("Graph") replace
}

**************************************************************************
*2011 with update data and normalized news shock (=1)

{
clear

*import excel Data.xlsx, firstrow
import delimited using govdat3908.csv
drop if quarter<1947
gen qdate = q(1947q1)+_n-1
format qdate %tq
tsset qdate
    
gen t = _n
gen t2 = t^2
gen t3 = t^3


gen rwbus = nwbus/pbus

merge 1:1 qdate using update
keep if _merge==3
drop _merge

local varlist = "rgdp rcons rcnd rcsv rcdur rcndsv rinv rinvfx rnri rres tothours tothoursces rgov rdef"

foreach var of local varlist {
  gen l`var' = log(`var'/pop)
}

local varlist = "totpop rwbus cpi pgdp"

foreach var of local varlist {
  gen l`var' = log(`var')

}
replace newsy = 1 if newsy!=0
save project_norm, replace


* VARS THAT USE STANDARD IDENTIFICATION METHOD;
var lg ly lrcndsv lrinvfx ltothoursces lrwbus taxy unemp, lags(1/4) exog(t t2)
varirf create irfgov_4, step(20) bs rep(500) set(irfgov_4, replace)
varirf table oirf, impulse(lg) response(lg ly lrcndsv lrinvfx ltothoursces lrwbus taxy unemp) std
*******************************************************
*Normalizing the IRF Shocks
use irfgov_4.irf, clear
sort irfname impulse response step
sum oirf if impulse=="lg" & response=="lg"
scalar mm = r(max)
gen max = mm
replace oirf=oirf*(1/max)
replace stdoirf = stdoirf*(1/max)
gen u90 = oirf  + 1.645* stdoirf
gen d90 = oirf  - 1.645* stdoirf
save irfgov_4.irf,replace

use project_norm, clear

* VARS THAT USE SHOCKS TO RAMEY-SHAPIRO MILITARY DATES;
var newsy lg ly lrcndsv lrinvfx ltothoursces lrwbus taxy unemp, lags(1/4) exog(t t2)
varirf create irfwar_4, step(20) bs rep(500) set(irfwar_4, replace)
varirf table oirf, impulse(newsy) response(lg ly lrcndsv lrinvfx ltothoursces lrwbus taxy unemp) std
*******************************************************
*Normalizing the IRF Shocks
use irfwar_4.irf, clear
sort irfname impulse response step
sum oirf if impulse=="newsy" & response=="newsy"
scalar mm = r(max)
gen max = mm
replace oirf=oirf*(1/max)
replace stdoirf = stdoirf*(1/max)
gen u90 = oirf  + 1.645* stdoirf
gen d90 = oirf  - 1.645* stdoirf
save irfwar_4.irf,replace

***************************************************************
*IRF Generation
*
*Standard VAR
use irfgov_4.irf, clear
twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "lg", legend(off) xlabel(0 (5) 20)  title("Government Spending", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lg_gov2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "ly", legend(off) xlabel(0 (5) 20)  title("GDP", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename ly_gov2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "lrcndsv", legend(off) xlabel(0 (5) 20)  title("Consumption, ndur + serv", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrcndsv_gov2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "lrinvfx", legend(off) xlabel(0 (5) 20)  title("Investment, nonres + res", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrinvfx_gov2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "ltothoursces", legend(off) xlabel(0 (5) 20)  title("Total Hours", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename ltothoursces_gov2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "lrwbus", legend(off) xlabel(0 (5) 20)  title("Real Wages", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrwbus_gov2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "taxy", legend(off) xlabel(0 (5) 20)  title("Tax Rates", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename taxy_gov2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "lg" & response == "unemp", legend(off) xlabel(0 (5) 20)  title("Unemployment Rate", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename unemp_gov2, replace


*Military News
use irfwar_4.irf, clear
twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "lg", legend(off) xlabel(0 (5) 20)  title("Government Spending", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lg_war2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "ly", legend(off) xlabel(0 (5) 20)  title("GDP", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename ly_war2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "lrcndsv", legend(off) xlabel(0 (5) 20)  title("Consumption, ndur + serv", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrcndsv_war2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "lrinvfx", legend(off) xlabel(0 (5) 20)  title("Investment, nonres + res", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrinvfx_war2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "ltothoursces", legend(off) xlabel(0 (5) 20)  title("Total Hours", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename ltothoursces_war2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "lrwbus", legend(off) xlabel(0 (5) 20)  title("Real Wages", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename lrwbus_war2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "taxy", legend(off) xlabel(0 (5) 20)  title("Tax Rates", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename taxy_war2, replace

twoway(rarea u90 d90  step,fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
(line oirf step, lcolor(blue) lpattern(solid) lwidth(thick)) ///
 if impulse == "newsy" & response == "unemp", legend(off) xlabel(0 (5) 20)  title("Unemployment Rate", color(black) size(medsmall)) ///
ytitle("", size(medsmall)) xtitle("quarter", size(medsmall)) ///
graphregion(color(white)) plotregion(color(white))
gr rename unemp_war2, replace

*Standard 
gr combine lg_gov2 ly_gov2 ltothoursces_gov2 lrcndsv_gov2 lrinvfx_gov2 lrwbus_gov2 taxy_gov2 unemp_gov2, ///
graphregion(color(white)) plotregion(color(white))

*Military
gr combine lg_war2 ly_war2 ltothoursces_war2 lrcndsv_war2 lrinvfx_war2 lrwbus_war2 taxy_war unemp_war, ///
graphregion(color(white)) plotregion(color(white))

*Together 1
gr combine lg_gov2 lg_war2 ly_gov2 ly_war2 ltothoursces_gov2 ltothoursces_war2 lrcndsv_gov2 lrcndsv_war2 , ///
graphregion(color(white)) plotregion(color(white)) colf r(4) c(2)

gr combine lg_gov2 lg_war2, ///
graphregion(color(white)) plotregion(color(white))

gr combine lrinvfx_gov2 lrinvfx_war2 lrwbus_gov2 lrwbus_war2 taxy_gov2 taxy_war2 unemp_gov2 unemp_war2, ///
graphregion(color(white)) plotregion(color(white))


graph export "Normalized.png", as(png) name("Graph") replace
}