{smcl}
{* 10jul2003/12mar2004}{...}
{hline}
help for {hi:rround}
{hline}

{title:Random rounding to base 3} 

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:rround} {varlist}
[{cmd:using} {it:filename}]
[{cmd:,} 
{opt harm:onize}
]


{title:Description}

{p 4 4 2}{cmd:rround} randomly rounds values up or down to the nearest multiple of 3. 
Values are rounded to the nearest multiple of 3 with a probability of 2/3,
and the second nearest multiple with a probability of 1/3. Values that are
already multiples of 3 are left unchanged. 

{p 4 4 2}For each variable provided in {it:varlist}, {cmd:rround} generates an additional 
variable named the same but with the suffix _rr. Each observation of the new variables is a 
randomly rounded value of the corresponding observation in the provided variable. 
The variables provided in {it:varlist} are left unchanged.

{p 4 4 2}There are three different modes. Without any option, {cmd:rround} randomly rounds
each value independently. With the option {cmd:harmonize}, the program will round 
the same values across the provided variables in the same direction. When providing a filename,
{cmd:rround} will use this file to save pairs that contain unrounded and the randomly rounded values,
and use the same randomly rounded value every time the same unrounded value comes up. 
This allows consistent rounding in the same direction across Stata sessions and datasets.
The program uses
Stata's data {helpb frames} and therefore requires Stata version 16 or later.

{title:Options} 

{p 4 8 2}{cmd:harmonize} rounds the same values within one variable in the same direction. 
This is achieved by using the first obtained random round for all cases. Note that the same value in different 
variables may be rounded to different multiples of 3.
 
{p 4 8 2}{cmd:using} {it:filename} creates and saves a Stata dataset with the provided name,
containing pairs of unrounded and randomly rounded values. For each unrounded value,
{cmd:rround} checks if the value is already included in {it:filename}, and uses the
corresponding rounded value if this is the case. If not, it will use a newly generated
random round and write the pair to {it:filename}.
If {it:filename} already exists, it will use all included unrouded-rounded pairs, append newly
generated unrounded-rounded pairs as necessary and overwrite {it:filename} with the updated file. 
 
{title:Examples} 

{p 4 4 2} This example uses collapse to produce counts of a categorial variable. Then, the corresponding
randomly rounded counts are generated with {cmd:rround}.

	{com}sysuse auto
	{com}gen count=1
	{com}collapse (sum) count, by(rep78)
	{com}rround count
	{com}list
    {txt}
           {c TLC}{hline 7}{c -}{hline 7}{c -}{hline 10}{c TRC}
           {c |} {res}rep78   count   count_rr {txt}{c |}
           {c LT}{hline 7}{c -}{hline 7}{c -}{hline 10}{c RT}
        1. {c |} {res}    1       2          3 {txt}{c |}
        2. {c |} {res}    2       8          9 {txt}{c |}
        3. {c |} {res}    3      30         30 {txt}{c |}
        4. {c |} {res}    4      18         18 {txt}{c |}
        5. {c |} {res}    5      11          9 {txt}{c |}
           {c LT}{hline 7}{c -}{hline 7}{c -}{hline 10}{c RT}
        6. {c |} {res}    .       5          6 {txt}{c |}
           {c BLC}{hline 7}{c -}{hline 7}{c -}{hline 10}{c BRC}


{p 4 4 2} This example uses Stata's data {helpb frames} to collect the results of two t-tests, 
and {cmd:rround} to round the number of involved observations. 
Note that {cmd:rround} here rounds the same count
of the same variable in the same direction because of the {cmd:harmonize} option.

	{com}sysuse auto
	{com}frame create tframe str10 varname mean1 count1 mean2 count2 pvalue
	{com}ttest price, by(foreign)
	{com}frame post tframe ("price") (`r(mu_1)') (`r(N_1)') (`r(mu_2)') (`r(N_2)') (`r(p)')
	{com}ttest mpg, by(foreign)
	{com}frame post tframe ("mpg") (`r(mu_1)') (`r(N_1)') (`r(mu_2)') (`r(N_2)') (`r(p)')
	{com}frame change tframe
	{com}rround count1 count2, harmonize
	{com}list, ab(9)
	{txt}
           {c TLC}{hline 9}{c -}{hline 10}{c -}{hline 8}{c -}{hline 10}{c -}{hline 8}{c -}{hline 10}{c -}{hline 11}{c -}{hline 11}{c TRC}
           {c |} {res}varname      mean1   count1      mean2   count2     pvalue   count1_rr   count2_rr {txt}{c |}
           {c LT}{hline 9}{c -}{hline 10}{c -}{hline 8}{c -}{hline 10}{c -}{hline 8}{c -}{hline 10}{c -}{hline 11}{c -}{hline 11}{c RT}
        1. {c |} {res}  price   6072.423       52   6384.682       22   .6801851          54          21 {txt}{c |}
        2. {c |} {res}    mpg   19.82692       52   24.77273       22   .0005254          54          21 {txt}{c |}
           {c BLC}{hline 9}{c -}{hline 10}{c -}{hline 8}{c -}{hline 10}{c -}{hline 8}{c -}{hline 10}{c -}{hline 11}{c -}{hline 11}{c BRC}


{p 4 4 2} This example uses the Stata ado {helpb parmest} (available at SSC) to store three estimation results in Stata datasets on disk. 
Then, the datasets are loaded and {cmd:rround} rounds the regressions' number of observations. The program is called with 
the {cmd:using} {it:filename} syntax, so the rounding happens consistently in the same direction, and an additional Stata
dataset autoround.dta is saved with the two pairs of unrounded and rounded counts.

	{com}sysuse auto	
	{com}reg price mpg
	{com}parmest, saving(model1, replace) escal(N) ylabel idstr(simple)
	{com}reg price mpg weight
	{com}parmest, saving(model2, replace) escal(N) ylabel idstr(adjusted)
	{com}reg price mpg weight if foreign==0
	{com}parmest, saving(model3, replace) escal(N) ylabel idstr(domestic)	
	{com}use model1
	{com}append using model2
	{com}append using model3
	{com}rename es_1 count
	{com}rround count using autoround.dta
	{com}list idstr estimate stderr count count_rr if parm=="mpg"
	{txt}
           {c TLC}{hline 10}{c -}{hline 12}{c -}{hline 11}{c -}{hline 7}{c -}{hline 10}{c TRC}
           {c |} {res}   idstr     estimate      stderr   count   count_rr {txt}{c |}
           {c LT}{hline 10}{c -}{hline 12}{c -}{hline 11}{c -}{hline 7}{c -}{hline 10}{c RT}
        1. {c |} {res}  simple   -238.89435   53.076687      74         72 {txt}{c |}
        3. {c |} {res}adjusted   -49.512221   86.156039      74         72 {txt}{c |}
        6. {c |} {res}domestic    237.69095   139.03342      52         51 {txt}{c |}
           {c BLC}{hline 10}{c -}{hline 12}{c -}{hline 11}{c -}{hline 7}{c -}{hline 10}{c BRC}

	

{title:Author} 

{p 4 4 2} 
Thomas Schober, Auckland University of Technology {break}
thomas.schober@aut.ac.nz


