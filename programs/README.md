# Merge various OPM datasets (Buzzfeed, FOIA 2013, FOIA 2016, Fedscope) by exact match. 

Compute the distribution of number of matches

# Availability of Data
Cleaning of FOIA 2016 and Buzzfeed done in /home/ssgprojects/project0002/cdl77/opm-clean/
## Locations at Cornell

```r
kable(opmlocs)
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> x </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> /data/clean/opm-foia </td>
  </tr>
  <tr>
   <td style="text-align:left;"> /ssgprojects/project0002/cdl77/opm-clean/outputs/2016 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> /ssgprojects/project0002/cdl77/opm-clean/outputs/buzzfeed </td>
  </tr>
  <tr>
   <td style="text-align:left;"> /data/clean/opm </td>
  </tr>
</tbody>
</table>

Sources: 

  + OPM 		"/data/doc/opm/SRC.txt"
  + Buzzfeed 	"/data/doc/opm-foia/Buzzfeed-20170524-Were Sharing A Vast Trove Of Federal Payroll Records.pdf"
  + Cornell-FOIA 2013 "/data/doc/opm-foia/20131126154301380.pdf"
  + Cornell-FOIA 2016 "/data/doc/opm-foia/OPM letter FOIA response 201611.pdf"
Fedscope 	"/data/doc/opm/FS_Employment_Sep2011_Documentation.pdf"


## OPM Buzzfeed
  Notes: 
    data available from 1973q3-2014q2
    No DoD data from 1992q4-2013q3
    qsub no longer working on ECCO, run with bash code
      There seems to be problems when I try to run all files in one go, so I'm running in chunks        
    Only kept 1999q4 onward since FOIA 2013, 2016, and Fedscope only begins after 1999q4

## OPM 
