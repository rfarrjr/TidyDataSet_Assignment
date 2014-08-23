# Loads data for this analysis and caches it in a subdirectory called ./data
# To reload simply delete the ./data directory and re-run.
load.data <- function() {
  dateDownloaded <- Sys.time()
  if (!file.exists("data")) {
    dir.create("data")
    
    temp <- tempfile()
    print(temp)
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url, temp, method="curl")
    unzip(temp, exdir = "data")
    unlink(temp)
    
    # capture download time
    fout <- file("data/downloaded.txt")
    writeLines(c(as.character(dateDownloaded)), fout)
    close(fout)
    
    dateDownloaded
  } else {
    fname <- "data/downloaded.txt"
    dateDownloaded <<- as.POSIXct(readChar(fname, file.info(fname)$size))
  }
}

# Reads the test and train datasets and merges them into a single dataframe.
read.and.merge <- function() {
  XTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt", header=FALSE)
  XTrain$Activity <- read.table("./data/UCI HAR Dataset/train/y_train.txt", header=FALSE)$V1
  XTrain$Subject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", header=FALSE)$V1
  
  XTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt", header=FALSE)
  XTest$Activity <- read.table("./data/UCI HAR Dataset/test/y_test.txt", header=FALSE)$V1
  XTest$Subject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", header=FALSE)$V1
  
  merge(XTrain, XTest, all=TRUE)
}

# This method updates the activity to a descriptive name
transform.activity <- function(DF) {  
  #update activity values
  activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", header=FALSE)
  transform(DF, Activity = activityLabels$V2[Activity])
}

group.and.summarize <- function(DF) {
  x <- split(DF, list(DF$Activity, DF$Subject))
  
  # build summary of the means for each activity and subject
  summarized <- sapply(x, function(df) { colMeans(df[1:(ncol(DF)-2)]) })
  
  #transpose and convert to a data frame
  df <- as.data.frame(t(summarized))
  
  #need to add back in the Activity and Subject columns
  df$Activity <- as.character(lapply(rownames(df), function(x) { strsplit(x, "\\.")[[1]][1] }))
  df$Subject <- as.numeric(lapply(rownames(df), function(x) { strsplit(x, "\\.")[[1]][2] }))
  
  df
}

###### MAIN Analysis

dateDownloaded <- load.data()

DF <- read.and.merge()

DF <- transform.activity(DF)

#read in features so we can give the col names meaning and filter to only mean/std vars
features <- read.table("./data/UCI HAR Dataset/features.txt", header=FALSE, stringsAsFactors = FALSE)

#filter to mean or stddev
filter <- grepl("-mean", features$V2) | grepl("-std", features$V2)
filter[562] <- TRUE #keep activity column
filter[563] <- TRUE #keep subject column

#add new features
features[562,] <- c(562, "Activity")
features[563,] <- c(563, "Subject")

# filter data and features
features <- features[filter,]
DF <- DF[,filter]

# set column names to something meaninful
colnames(DF) <- features$V2

#write out features code page
write.table(features$V2, "features.txt", col.names = FALSE, quote = FALSE)

DF <- group.and.summarize(DF)

#write the tidy data set
write.table(DF, "tidy_data.txt", row.names = FALSE)
