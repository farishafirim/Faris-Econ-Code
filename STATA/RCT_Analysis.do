clear 
capture log close
set more off
set logtype text
cd "G:\My Drive\Courseworks\Adv Econ Dev\PS4\" 
log using PS4log_FarisMakarim.log, replace
use ps4.dta

*****************************************************************************

*2.2. Consider only children in the 185 "control" villages (program=0). Calculate the fraction (for all control villages *together) of children that attended school in 1997, separately for each age level from 6 to 16. (Hint: use the "by" option of the summarize command, i.e. "by age97: summarize enroll97.")

sort age97

preserve
keep if age97>=6 & age97<=16
by age97: summarize enroll97 if program==0 
restore

table age97 if program == 0 & age97>=6 & age97<=16, statistic(mean enroll97)

*2.3. Considering the same children as in part 2.2, calculate the fraction of children that worked in the week prior to the survey in 1997, separately for each age level from 8 to 16. (The survey did not ask whether children younger than 8 had worked.) Report your findings from 2.2 and 2.3 together in a simple table. (You can make the table in Excel or Word; you do not have to use Stata to make the table.) 

sort age97
preserve
keep if age97>=8 & age97<=17
by age97: summarize work97 if program==0
restore

table age97 if program == 0 & age97>=8 & age97<=16, statistic(mean work97)

*****************************************************************************

*3. Testing randomization
*3.1. Calculate the means and the standard errors of the following variables for children ages 6-16 in 1997,1 separately for the group of treatment villages and the group of control villages: (a) age97, (b) grade97, (c) enroll97. Use the "collapse" command, which will convert the individual-level dataset to a dataset with averages, standard deviations and counts, i.e. "collapse (mean) age97mean = age97 … (sd) age97sd = age97 … (count) age97count = age97 … , by(program)". (Note that in place of the ellipses (…) you will put other variables (i.e. enroll97mean = enroll97).) After collapsing the dataset, calculate the standard errors of the means from the standard deviations, as discussed in class.

collapse (mean) age97mean = age97 grade97mean = grade97 enroll97mean = enroll97 (sd) age97sd = age97 grade97sd = grade97 enroll97sd = enroll97 (count) age97count = age97 grade97count = grade97 enroll97count = enroll97 , by(program)

gen age97se = age97sd / sqrt(age97count)
gen grade97se = grade97sd / sqrt(grade97count)
gen enroll97se = enroll97sd / sqrt(enroll97count)

list program *mean
list program *se

*****************************************************************************

*3.2. Calculate the difference in means for the treatment and control groups for the three variables from part 3.1, and the standard error of this difference. Calculate the 95% confidence interval for the difference in means around your estimate. Does zero lie outside of the 95% confidence interval? In other words, can we reject the hypothesis that the means for the treatment and control groups are the same? Your written answer should include the formula you used to calculate the confidence intervals.

gen diffage = age97mean[2]-age97mean[1]
gen diffgrade = grade97mean[2]-grade97mean[1]
gen diffenroll = enroll97mean[2]-enroll97mean[1]

gen diffagese = sqrt((age97sd[2]^2/age97count[2])+(age97sd[1]^2/age97count[1]))
gen diffgradese = sqrt((grade97sd[2]^2/grade97count[2])+(grade97sd[1]^2/grade97count[1]))
gen diffenrollse = sqrt((enroll97sd[2]^2/enroll97count[2])+(enroll97sd[1]^2/enroll97count[1]))

gen lbage=diffage-1.95996398454005*diffagese
gen ubage=diffage+1.95996398454005*diffagese
gen lbgrade=diffgrade-1.95996398454005*diffgradese
gen ubgrade=diffgrade+1.95996398454005*diffgradese
gen lbenroll=diffenroll-1.95996398454005*diffenrollse
gen ubenroll=diffenroll+1.95996398454005*diffenrollse

list diffage diffgrade diffenroll
list diffagese diffgradese diffenrollse
list lbage ubage lbgrade ubgrade lbenroll ubenroll

*3.3. Test the null hypothesis that the means for age97, grade97, and enroll97 are equal using the Stata "ttest" command. (The syntax is e.g. "ttest age97, by(program) unequal reverse."2 ) Check that the confidence intervals you constructed in 3.2 are correct. (Note that you should focus on the reported statistics for Ha: diff != 0, which corresponds to the twotailed test of the hypothesis that the means are equal against the alternative hypothesis that they are not equal.)

use ps4.dta,clear
ttest age97, by(program) unequal reverse
ttest grade97, by(program) unequal reverse
ttest enroll97, by(program) unequal reverse


*3.6. Bonus question (3 points extra credit). If one is testing a large number of variables separately for pre-treatment differences in means, it is possible that some variables will have significant differences even if randomization was carried out successfully. In such cases, one should test the joint hypothesis that all the differences in means are zero. There are several ways to do this in Stata, but perhaps the simplest is to use the "sureg" command (including the "small" and "dfk" options, with "program" as the right-hand side variable in three equations) followed by the "test" command. Implement this procedure, testing the joint hypothesis that the differences in means of age97, grade97, and enroll97 are zero.

sureg (age97 program) ///
      (grade97 program) ///
      (enroll97 program), small dfk

test ([age97]program = 0) ([grade97]program = 0) ([enroll97]program = 0)

*****************************************************************************
*4. Evaluating the impact of the program 
*4.1. Assuming that the randomization process was indeed carried out successfully, consider the following four null hypotheses: 
*(a) the program had no effect on the school attendance rate of children of primary-school age (ages 6-11 in 1998), 
*(b) the program had no effect on the fraction of children of primary-school age who worked, 
*(c) the program had no effect on the school attendance rate of children of secondary-school age (ages 12-16 in 1998), 
*(d) the program had no effect on the fraction of children of secondary-school age who worked.3 
*Test these hypotheses following the same procedure as in part 3.3 above. (Hint: you may find the "if" option for the ttest command useful, i.e. "ttest enroll98 if age98 >= 6 & age98 <= 11, by(program) unequal".) Can we reject any of these hypotheses? Which ones? At what level of confidence?

ttest enroll98 if age98>=6 & age98<=11, by(program) unequal reverse 
ttest work98 if age98>=6 & age98<=11, by(program) unequal reverse 
ttest enroll98 if age98>=12 & age98<=16, by(program) unequal reverse 
ttest work98 if age98>=12 & age98<=16, by(program) unequal reverse 

*4.2. Test the null hypothesis that the program had no effect on the likelihood of students finishing primary school to continue on to secondary school (as indicated by the variable continued98.) Can we reject the hypothesis? At what level of confidence?
ttest continued98, by(program) unequal reverse

*4.3. Repeat your calculations from 4.1-4.2, but separately for boys and girls.
ttest enroll98 if age98>=6 & age98<=11 & male==1, by(program) unequal reverse 
ttest work98 if age98>=6 & age98<=11 & male==1, by(program) unequal reverse 
ttest enroll98 if age98>=12 & age98<=16 & male==1, by(program) unequal reverse 
ttest work98 if age98>=12 & age98<=16 & male==1, by(program) unequal reverse 
ttest continued98 if male==1, by(program) unequal reverse

ttest enroll98 if age98>=6 & age98<=11 & male==0, by(program) unequal reverse 
ttest work98 if age98>=6 & age98<=11 & male==0, by(program) unequal reverse 
ttest enroll98 if age98>=12 & age98<=16 & male==0, by(program) unequal reverse 
ttest work98 if age98>=12 & age98<=16 & male==0, by(program) unequal reverse 
ttest continued98 if male==0, by(program) unequal reverse