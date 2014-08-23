This code provides a tidied dataset from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.

## Study Design

run_analysis.R performs the following anlysis:
1. takes the train and test datasets and merges them together.
2. filters the data to only mean and std measurements along with adding the Activity and Subject variables
3. updates the activity variable with descriptive values
4. summarizes the data by computing the average of each measurement for each activity and each subject.
5. writes the tidied dataset to tidy_data.txt in the working directory.

## Running

To run the analysis simply source("run_analysis.R").  It will download the data set the first time it is run.  Additional runs will use the cached dataset.  

If you wich to redownload the data simply delete the ./data directory in the working directory and re-source the script.

### Feature info

See *feature_info.txt* from the downloaded dataset for details of the original measurements.

The features were filtered down to only mean and std measurements of the combined test and train datasets provided in the zip.   The activity and subject data were also added as features to the tidied dataset produced by run_analysis.R.

The complete list of variables of each feature vector is available in '[features.txt](features.txt)'
