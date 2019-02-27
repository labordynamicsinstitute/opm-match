# ###########################
# CONFIG: define paths and filenames for later reference
# ###########################

# Change the basepath depending on your system

basepath <- rprojroot::find_rstudio_root_file()

# Main directories
dataloc <- file.path(basepath, "data","source")
interwrk <- file.path(basepath, "data","interwrk")
Outputs <- file.path(basepath, "analysis" )

programs <- file.path(basepath)

for ( dir in list(dataloc,interwrk,Outputs)){
	if (file.exists(dir)){
	} else {
	dir.create(file.path(dir),recursive = TRUE)
	}
}

# OPM data on ECCO

# base on the specific server
srvbase <- "/data/"
opmlocs <- c(file.path(srvbase,"clean/opm-foia/somewhere"), 
			 file.path(srvbase,"clean/opm-foia/else"), 
			 file.path(srvbase,"clean/opm-buzzfeed"),
			 file.path(srvbase,"clean/opm"))

