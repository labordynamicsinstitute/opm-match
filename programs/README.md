# opm-match programs
- Author: Daniel Lin
- Last Modified: 3/07/2019	(Daniel Lin)

Format all OPM datasets - FOIA 2013, FOIA 2016, Fedscope, Buzzfeed - for matching. 
# Availability of Data
Cleaning of FOIA 2013, FOIA 2016, and Buzzfeed done in /home/ssgprojects/project0002/cdl77/opm-clean/

These programs are ran under the following directory structure:

## Inputs
Cleaned full data for the 4 OPM sources, from /ssgprojects/project0002/cdl77/opm-clean/outputs

For programs that were used to generate this from raw data, see the /ssgprojects/project0002/cdl77/opm-clean/programs directory.

OPM data are Stata files in ../inputs under the name scheme
```
opmfoia13_all.dta
opmfoia16_all.dta
opmfeds_all.dta
opmbuzz_all.dta
```
The full data files will be partitioned into annual files for more efficient matching time. For example:
```
buzz_2000.dta
buzz_2001.dta
...
buzz_2012.dta
```

## Outputs
The matched datasets in ../outputs are under the name scheme
```
merge_opm_2000.dta
merge_opm_2001.dta
...
merge_opm_2012.dta
```

The distribution of matches are recorded in opm_merge_distribution (not automated yet, recorded manually)


## To run
First, update directory in each program under "globals" for do files

### Programs
Programs in this folder will recode different OPM datas to consistent format for merging. The data will then be partitioned into annual files, and the 4 OPM files will be merged by year. The order of merging is 
+ FOIA 2013 with FOIA 2016, 
+ Result of the previous merge with Fedscope
+ Result of the previous merge with Buzzfeed

### Run in following order

  Format and recode all OPM datas into comparable files
```      
01.format.qsub
```
  Merge all OPM files FOIA 2013 - FOIA 2016 - Fedscope - Buzzfeed, and provide distributions
```
02.merge_opm.qsub
```


### Details and Assumptions
#### 01.format.qsub
1. With 2 datasets with different levels of data protection, I generate to the most protect format. 
  - i.e. FOIA 2013 has actual service lengths, and FOIA 2016 has ranges of service length. The ranges of service length is added to FOIA 2013.
2. Recoding conversions are noted at the end 

#### 02.merge_opm.qsub
1. joinby statement is used because most observations cannot be UNIQUELY identified
2. The results of this is creation of all pairwise combinations of all matches that cannot be uniquely identified
  - This significantly affects the distribution of exact matches
  - I cannot simply drop the pairwise combinations because they are informative in later merges
3. I included an unique identifier for every observation in each of the 4 OPM data sets
  - This provides an identification for exact matches and "ambiguous matches"
  - From this I can arrive at the correct distribution
4. The merges are partitioned in to annual files because the size of the files explode due to the use of joinby statement



# Availability of Data
Cleaning of FOIA 2013, FOIA 2016, and Buzzfeed done in /home/ssgprojects/project0002/cdl77/opm-clean/
## Locations at Cornell

```r
kable(opmlocs)
```

## Notes
Variable Conversion

| EHF | OPM 
| --- | ---:
| sein | Agency
| seinunit | Duty Station
| total_weight | =1
| w_stfid | state
| w_block | city
| owner | =1
| age_c | age
| sex | sex
| educ_c | educ_c
| race | =0
| ethnicity | =0
| firmage | firmage
| firmsize_fuzz | =1

age

| FOIA 2013		| FOIA 2016		| Fedscope		| Buzzfeed 
| ---			| ---			| ---			| ---	 
| `< 20`    		| `1`			| `A`			| `< 20`   
| `20-24`   		| `2`			| `B`			| `20-24`  
| `25-29`  		| `3`			| `C`			| `25-29` 
| `30-34` 		| `4`			| `D`			| `30-34` 
| `35-39`		| `5`			| `E`			| `35-39` 
| `40-44`		| `6`			| `F`			| `40-44` 
| `45-49`		| `7`			| `G`			| `45-49` 
| `50-54`		| `8`			| `H`			| `50-54` 
| `55-59` 		| `9`			| `I`			| `55-59`  
| `60-64` 		| `10`			| `J`			| `60-64` 
| `65+` 		| `11`			| `K`			| `65-69 & 70-74 & 75+`  
| 			| 			| `Z`			| UNSP 

Service length

| FOIA 2013		| FOIA 2016		| Fedscope		| Buzzfeed 
| ---			| ---			| ---			| ---	 
| `VALUE`   		| `1`			| `VALUE`		| `< 1`   
| `VALUE` 		| `2`			| `VALUE`		| `1-2`  
| `VALUE`		| `3`			| `VALUE`		| `3-4` 
| `VALUE`		| `4`			| `VALUE`		| `5-9` 
| `VALUE`		| `5`			| `VALUE`		| `10-14` 
| `VALUE`		| `6`			| `VALUE`		| `15-19` 
| `VALUE`		| `7`			| `VALUE`		| `20-24` 
| `VALUE`		| `8`			| `VALUE`		| `25-29` 
| `VALUE`		| `9`			| `VALUE`		| `30-34 & 35+`  
| 			| 			| 			| UNSP 

Occupational Category

| FOIA 2013		| FOIA 2016		| Fedscope		| Buzzfeed 
| ---			| ---			| ---			| ---	 
| `A` 			| `A`			| `2`			| `A`   
| `B`  			| `B`			| `6`			| `B`  
| `C`			| `C`			| `4`			| `C` 
| `O`			| `O`			| `5`			| `O` 
| `P`			| `P`			| `1`			| `P` 
| `T`			| `T`			| `3`			| `T` 
| `*`			| `*`			| `9`			| `*` 



