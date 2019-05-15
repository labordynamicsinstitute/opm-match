# opm-match programs
- Author: Daniel Lin
- Last Modified: 3/07/2019	(Daniel Lin)

Format all OPM datasets - FOIA 2013, FOIA 2016, Fedscope, Buzzfeed - for matching. 
# Availability of Data
Cleaning of FOIA 2013, FOIA 2016, and Buzzfeed done in /home/ssgprojects/project0002/cdl77/opm-clean/

These programs are ran under the following directory structure:

# Inputs
Cleaned full data for the 4 OPM sources, from /ssgprojects/project0002/cdl77/opm-clean/outputs

For programs that were used to generate this from raw data, see the /ssgprojects/project0002/cdl77/opm-clean/programs directory.

OPM data are Stata files in ../inputs under the name scheme
```
opmfoia13_all.dta
opmfoia16_all.dta
opmfeds_all.dta
opmbuzz_all.dta
```
The full data files will be partitioned into quarterly files for both better comparison and more efficient matching time. For example:
```
buzz_y2000q1.dta
buzz_y2000q2.dta
...
buzz_y2012q4.dta
```

# Outputs
The matched datasets in ../outputs are under the name scheme
```
binary_merge_foia13_foia16_y2000q1.dta
binary_merge_foia13_foia16_y2000q2.dta
...
binary_merge_foia13_foia16_y2012q4.dta
```

The distribution of matches are recorded in outputs/ 
```
merge_foia13_foia16_summary.csv
merge_foia13_feds_summary.csv
merge_foia13_buzz_summary.csv
```


# Programs
Programs in this folder will recode different OPM datas to consistent format for merging. The data will then be partitioned into annual files, and the 4 OPM files will be merged by year. The order of merging is 
+ FOIA 2013 with FOIA 2016, 
+ Result of the previous merge with Fedscope Old
+ Result of the previous merge with Buzzfeed

Then binary merges of
+ FOIA 2013 with FOIA 2016, 
+ FOIA 2013 with Fedscope Old
+ FOIA 2013 with Buzzfeed

Summary of matches and the relative contribution of each variable on the "uniqueness" of matching are produced in CSV files

## To run
First, update paths and merge_switches in programs/config.do 

## 01_format.do

This program formats and recodes all OPM datas into quarterly comparable files. Created longitudinal variables of tenure to agency, posting length to duty station, tenure to occupation, quarter-over-quarter earnings change. 

Note: Append all quarterly files to single file to produce longitudinal variables, then save results as quarterly files again for better matching. With 2 datasets with different levels of data protection, the most protect format is used for merge. I.e. topcoded salary levels vs actual salary. 

## 02_duplicate_tab.do

This program tabulates duplicates of given specified varlists for FOIA 2013 (Cornell1), FOIA 2016 (Cornell2), Fedscope, and Buzzfeed. The 3 varlists are all shared variables between FOIA 2013-FOIA 2016, FOIA 2013-Fedscope, and FOIA 2013-Buzzfeed.

Note: To do- update code to save results into CSV

## 03_merge_opm.do

This program merges the OPM datasets iteratively starting with FOIA 2013 with FOIA 2016 (I). Then merge result(I) with Fedscope. Then merge result(II) with Buzzfeed.

Note: Merge m:m is used because a full outer join is not needed. It is fine to lose duplicates in this exercise. Matches produced from duplicated items in Stata's merge m:m are not technically random (it is based on how the dataset is sorted), but since I didn't sort the data with regard to any of the non-merge variables, the match results should be fairly random. The merges are partitioned into quarterly files for matching.

## 04_binary_merge.do

This program creates 3 separate merge files using FOIA 2013 as the base: FOIA 2013-FOIA 2016, FOIA 2013-Fedscope, and FOIA 2013-Buzzfeed. The match rates are saved to outputs/binary_merge_summary.csv

Note: Merge m:m is used because a full outer join is not needed. It is fine to lose duplicates in this exercise. Matches produced from duplicated items in Stata's merge m:m are not technically random (it is based on how the dataset is sorted), but since I didn't sort the data with regard to any of the non-merge variables, the match results should be fairly random. The merges are partitioned into quarterly files for matching. The merge ratio is calculated as 1 subtracted by the ratio of unmatched from the master dataset to the total obs of master dataset, (1 - (unmatched_m/obs_m)).

For FOIA 2016, "security-related" agencies and occupations have blanked certain fields: id_foia16, name, duty_sta, cbsa, loc
	foia16a - no masking 
	foia16b - id_foia16 and name masked
	foia16c - id_foia16, name, duty_sta, cbsa, loc masked
	foia16b is merged separately without using longitudinal vars
	foia16c is merged separately without using duty_sta, cbsa, loc, and longitudinal vars


## 05_binary_contribution.do

This program produces a CSV file showing the merge variables in 04 by importance in terms of contribution to uniquness and matching is generated. The contributions are saved to outputs/contribution_binary_merge#.csv, where # indicates FOIA2013 - FOIA2016 merge (1), FOIA 2013-Fedscope merge (2), FOIA 2013-Buzzfeed merge(3)

Note: Relative contribution to uniqueness is measured by iteratively removing and adding one variable from the merge varlist. The changes in the numbers of nonduplicates from removing and adding the variable indicates it's relative contribution to uniqueness. A larger increase in nonduplicates indicates larger relative contribution to uniqueness.

## 06_attribute_carryforward.do

This program carrys forward the matched attributes in the FOIA 2013-FOIA 2016 merges to later FOIA 2016 files (2013q1-2016q1)

Note: Attributes are first assigned to matched FOIA 2016 pseudo ID. It is then assigned using the merge varlist. attribute assigned to the ID is dominant.

# Standardized Codes
```{r read_code1, include=FALSE}
topcode1 <- read_excel("standard_code.xlsx", sheet = "age") %>% select("Age Code","Buzzfeed","Cornell-FOIA 2013","Cornell FOIA 2016", "Fedscope-old")
kable(topcode1 %>% slice(1:10)) %>%
kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)
```

```{r read_code2, include=FALSE}
topcode2 <- read_excel("standard_code.xlsx", sheet = "loslvl") %>% select("Length of Service Codee","Buzzfeed","Cornell-FOIA 2013","Cornell FOIA 2016", "Fedscope-old")
kable(topcode2 %>% slice(1:10)) %>%
kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)
```

```{r read_code3, include=FALSE}
topcode3 <- read_excel("standard_code.xlsx", sheet = "paylvl") %>% select("Salary Code","Buzzfeed","Cornell-FOIA 2013","Cornell FOIA 2016", "Fedscope-old")
kable(topcode3 %>% slice(1:10)) %>%
kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)
```

```{r read_code4, include=FALSE}
topcode4 <- read_excel("standard_code.xlsx", sheet = "occ_cat") %>% select("Occupational Category","Buzzfeed","Cornell-FOIA 2013","Cornell FOIA 2016", "Fedscope-old")
kable(topcode4 %>% slice(1:10)) %>%
kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = F)
```



