##Pakages required
install.packages(c("keras","reticulate","tensorflow"))

##Set up miniconda environment if not already installed 
reticulate::install_miniconda()


#If minicinconda is installed, set r-miniconda path if required or not automatically picked
#Sys.setenv(RETICULATE_MINICONDA_PATH = "/path/to/r-miniconda")


##check path is properly set
##reticulate::py_config()

##Packages to be installed in miniconda environement 
reticulate::py_install(c("keras==2.4.3","h5py==2.10.0","tensorflow==2.4.1"),pip=TRUE)

