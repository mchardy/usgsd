# analyze us government survey data with the r language
# american time use survey
# 2003 - 2012

# if you have never used the r language before,
# watch this two minute video i made outlining
# how to run this script from start to finish
# http://www.screenr.com/Zpd8

# anthony joseph damico
# ajdamico@gmail.com

# if you use this script for a project, please send me a note
# it's always nice to hear about how people are using this stuff

# for further reading on cross-package comparisons, see:
# http://journal.r-project.org/archive/2009-2/RJournal_2009-2_Damico.pdf


################################################################
# Analyze the 2003 - 2012 American Time Use Survey file with R #
################################################################


# set your working directory.
# the ATUS 2003 - 2012 data files will be stored here
# after downloading and importing them.
# use forward slashes instead of back slashes

# uncomment this line by removing the `#` at the front..
# setwd( "C:/My Directory/ATUS/" )
# ..in order to set your current working directory



# define which years to download #

# uncomment this line to download all available data sets
# uncomment this line by removing the `#` at the front
# years.to.download <- c( 2003:2012 , "0307" , "0309" , "0310" , "0311" )

# uncomment this line to only download 2010
# years.to.download <- 2010

# uncomment this line to download, for example,
# 2005 and 2009-2011 and the '03-'11 multi-year file
# years.to.download <- c( 2005 , 2009:2011 , "0311" )



############################################
# no need to edit anything below this line #

# # # # # # # # #
# program start #
# # # # # # # # #

# specify the ftp path to the american time use survey on
# the bureau of labor statistics' website
ftp.dir <- "ftp://ftp.bls.gov/pub/special.requests/tus/"

# create a temporary file
tf <- tempfile()

# warning: this might behave differently on non-windows systems
# warning: this command must be run before any other
# internet-accessing lines in the session
setInternet2(TRUE)
# you also might need administrative rights
# on your computer to run `setInternet2`

# download the contents of the ftp directory
# to the temporary file
download.file( ftp.dir , tf )

# read the contents of that temporary file
# into working memory (a character object called `txt`)
txt <- readLines( tf )
# if the object `txt` contains the ftp's contents,
# you're cool.  otherwise, maybe look at this discussion
# http://stackoverflow.com/questions/5227444/recursively-ftp-download-then-extract-gz-files
# ..and tell me what you find.

# keep only lines with a link to data files
txt <- txt[ grep( "A HREF=\"/pub/special.requests/tus/" , txt ) ]

# isolate the zip filename #

# first, remove everything before the `special.requests/tus/`..
txt <- sapply( strsplit( txt , "/pub/special.requests/tus/" ) , "[[" , 2 )

# ..second, remove everything after the `.zip`
all.files.on.ftp <- sapply( strsplit( txt , '.zip\">' ) , "[[" , 1 )

# now you've got all the basenames
# in the object `all.files.on.ftp`

# remove all `lexicon` files.
# you can download a specific year
# for yourself if ya want.
all.files.on.ftp <-
	all.files.on.ftp[ !grepl( 'lexiconwex' , all.files.on.ftp ) ]



# begin looping through every atus year
# specified at the beginning of this program..
for ( year in years.to.download ){

	# create a year-specific directory
	# within your current working directory
	dir.create( paste0( "./" , year ) , showWarnings = FALSE )

	# find all zipped files specific to
	# the current year of data
	files.this.year <- 
		all.files.on.ftp[ grep( year , all.files.on.ftp ) ]
		
	# loop through each of those year-specific files..
	for ( curFile in files.this.year ){

		# build a character string containing the
		# full filepath to the current zipped file
		fn <- paste0( ftp.dir , curFile , ".zip" )
		
		# download the file
		download.file( fn , tf , mode = 'wb' )
		
		# extract the contents of the zipped file
		# into the current year-specific directory
		# and (at the same time) create an object called
		# `files.in.zip` that contains the paths on
		# your local computer to each of the unzipped files
		files.in.zip <- 
			unzip( tf , exdir = paste0( "./" , year ) )
		
		# find the data file
		csv.file <- 
			files.in.zip[ grep( ".dat" , files.in.zip , fixed = TRUE ) ]
		
		# read the data file in as a csv
		x <- read.csv( csv.file )
		
		# convert all column names to lowercase
		names( x ) <- tolower( names( x ) )
		
		# remove the _YYYY from the string containing the filename
		savename <- gsub( paste0( "_" , year ) , "" , curFile )

		# copy the object `x` over to another object
		# called whatever's in savename
		assign( savename , x )
		
		# delete the object `x` from working memory
		rm( x )
		
		# save the object named within savename
		# into an R data file (.rda) for easy loading later
		save( 
			list = savename , 
			file = paste0( "./" , year , "/" , savename , ".rda" ) 
		)
		
		# delete the savename object from working memory
		rm( list = savename )
		
		# clear up RAM
		gc()
		
		# delete the files that were unzipped
		# at the start of this loop,
		# including any directories
		unlink( files.in.zip , recursive = TRUE )
		
		# delete the temporary file
		# (which stored the zipped file)
		file.remove( tf )
		
	}
	
}

# print a reminder: set the directory you just saved everything to as read-only!
message( paste0( "all done.  you should set the file " , file.path( getwd() ) , " read-only so you don't accidentally alter these tables." ) )


# for more details on how to work with data in r
# check out my two minute tutorial video site
# http://www.twotorials.com/
