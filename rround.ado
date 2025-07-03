*! rround version 1.5 (3jul2025), Thomas Schober

cap program drop rround
program rround
	version 16
	syntax varlist(min=1) [using/] [, HARMonize]
	
	/****** checks: varlist ******/
	foreach V of varlist `varlist' {
		cap confirm numeric variable `V'
		if _rc {
			di as err `"`V' is not a numeric variable"'
			exit 
		}
		cap confirm variable `V'_rr
		if !_rc {
			di as err `"`V'_rr already exists"'
			exit 
		}
		cap confirm variable _rr_count_rr										// "temporary" variable needed for Stata 16 work around
		if !_rc {
			di as err `"_rr_count_rr already exists"'
			exit 
		}
	}	

	/****** checks: using file ******/	
	if "`using'" ~= "" {
		if substr("`using'",-4,.)~=".dta" local F = "`using'.dta" 				// if missing, append .dta to filename
			else local F = `"`using'"'
		capture confirm file `"`F'"'
		if _rc==0 {									
			qui d count_raw count_rr using `"`F'"'								// check if it includes variables count_raw and count_rr
		}
	}
		
	/****** simple random rounding of variables ******/
	if "`harmonize'" == "" & `"`using'"' == "" {
	foreach V of varlist `varlist' {
		tempvar F3 C3 N3 S3 
		qui gen double `F3' = 3*floor(`V'/3) 									// floor multiple of base
		qui gen double `C3' = 3*ceil(`V'/3)										// ceiling
		qui gen double `N3' = round(`V',3)										// nearest multiple 
		qui gen	double `S3' = cond(`F3'==`N3',`C3',`F3')						// second nearest
		qui gen double `V'_rr = cond(rbinomial(1,2/3)==1,`N3',`S3')				// rount to nearest with 2/3 probability
		qui compress `V'_rr														// compress at the end if possible
	}
	}
	
	/****** random rounding in data frame ******/			
	if "`harmonize'" ~= "" | "`using'" ~= "" {
	tempname id harmframe
	qui gen double `id' = _n 													// to restore sort order		
	local originalframe = c(frame)
	mata: count_raw = (.)														// stack multiple variables into one using MATA and load into harmframe
	foreach v of varlist `varlist' {
		mata: count_raw = count_raw \ st_data(.,"`v'")		
	}
	mata: count_raw = uniqrows(count_raw)
	mata: count_raw = select(count_raw,rowmissing(count_raw):==0)
	frame create `harmframe'
	frame change `harmframe'
	getmata count_raw, double
	
	// random rounding inside harmframe
	tempvar f3 c3 n3 s3 
	qui gen double `f3' = 3*floor(count_raw/3) 									// floor multiple of base
	qui gen double `c3' = 3*ceil(count_raw/3)									// ceiling
	qui gen double `n3' = round(count_raw,3)									// nearest multiple 
	qui gen	double `s3' = cond(`f3'==`n3',`c3',`f3')							// second nearest
	qui gen double count_rr = cond(rbinomial(1,2/3)==1,`n3',`s3')				// round to nearest with 2/3 probability
	qui compress count_rr														// compress at the end if possible
	qui d, short
	local totalvals = r(N)
	
	// if program is called using a FILE: use and update, or generate new file
	if "`using'" ~= "" {
		capture confirm file `"`F'"'
		if _rc==0 {	
			rename count_rr new_rr
			qui merge 1:1 count_raw using `"`F'"'
			qui count if _merge==1						
			dis "... using existing file `F', adding `r(N)' new values "				
			qui replace count_rr = new_rr if mi(count_rr)
			keep count_raw count_rr
		}
		qui count
		else dis "... creating new file `F', with `r(N)' values"				
		sort count_raw
		keep count_raw count_rr
		qui save `"`F'"', replace												// overwrite stored values on disk 
	}
	
	// get harmonised values from harmframe to original data
	frame change `originalframe'		
	foreach v of varlist `varlist' {
		qui frlink m:1 `v', frame(`harmframe' count_raw)
		qui frget count_rr, from(`harmframe') prefix(_rr_)						// Stata 16 workaround (error when renaming variable), first copy over
		rename _rr_count_rr `v'_rr												// then rename		
		drop `harmframe' 
	}			
	sort `id'																	// revert to original sorting
	}
end
exit
