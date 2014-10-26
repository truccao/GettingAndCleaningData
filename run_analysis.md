---
title: "Run_Analysis Project Homework"
output: html_document
---
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected. 

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following. 

    - Merges the training and the test sets to create one data set --> COMPLETED
    - Extracts only the measurements on the mean and standard deviation for each measurement. --> COMPLETED 
    - Uses descriptive activity names to name the activities in the data set --> COMPLETED
    - Appropriately labels the data set with descriptive variable names. --> COMPLETED

    - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. --> COMPLETED

<b>Set up environments</b>

Load required packages and define working directory, URL and name of the downloaded zipped file used for this
exercise.


```r
library(data.table)
```

```
## data.table 1.9.4  For help type: ?data.table
## *** NB: by=.EACHI is now explicit. See README to restore previous behaviour.
```

```r
library(reshape2)
current_wd <- getwd()
# Download the file under the name - "Dataset.zip" into the current working directory
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
inputDataFile <- "Dataset.zip"
```

<b>Download</b> the zipped input file into the current working directory and unzip it with REPLACE option.



<b>List</b> all the files under the designated sub-directory


```
##  [1] "activity_labels.txt"                         
##  [2] "features_info.txt"                           
##  [3] "features.txt"                                
##  [4] "README.txt"                                  
##  [5] "test/Inertial Signals/body_acc_x_test.txt"   
##  [6] "test/Inertial Signals/body_acc_y_test.txt"   
##  [7] "test/Inertial Signals/body_acc_z_test.txt"   
##  [8] "test/Inertial Signals/body_gyro_x_test.txt"  
##  [9] "test/Inertial Signals/body_gyro_y_test.txt"  
## [10] "test/Inertial Signals/body_gyro_z_test.txt"  
## [11] "test/Inertial Signals/total_acc_x_test.txt"  
## [12] "test/Inertial Signals/total_acc_y_test.txt"  
## [13] "test/Inertial Signals/total_acc_z_test.txt"  
## [14] "test/subject_test.txt"                       
## [15] "test/X_test.txt"                             
## [16] "test/y_test.txt"                             
## [17] "train/Inertial Signals/body_acc_x_train.txt" 
## [18] "train/Inertial Signals/body_acc_y_train.txt" 
## [19] "train/Inertial Signals/body_acc_z_train.txt" 
## [20] "train/Inertial Signals/body_gyro_x_train.txt"
## [21] "train/Inertial Signals/body_gyro_y_train.txt"
## [22] "train/Inertial Signals/body_gyro_z_train.txt"
## [23] "train/Inertial Signals/total_acc_x_train.txt"
## [24] "train/Inertial Signals/total_acc_y_train.txt"
## [25] "train/Inertial Signals/total_acc_z_train.txt"
## [26] "train/subject_train.txt"                     
## [27] "train/X_train.txt"                           
## [28] "train/y_train.txt"
```

<b>Read</b> subject, activity and training/test files from the designated working directory.


```r
subjectTrainingDS <- fread(file.path(inputDirPath, "train", "subject_train.txt"))
subjectTestDS     <- fread(file.path(inputDirPath, "test" , "subject_test.txt" ))

YTrainingDS   <- fread(file.path(inputDirPath, "train", "y_train.txt"))
YTestDS       <- fread(file.path(inputDirPath, "test" , "y_test.txt" ))

XTrainingDS <- read.table(file.path(inputDirPath, "train", "X_train.txt"))
XTestDS     <- read.table(file.path(inputDirPath, "test" , "X_test.txt" ))
```

<b>Combine two subject files</b> into one and rename its column


```r
mergedSubjectDS <- rbind(subjectTrainingDS, subjectTestDS)
setnames(mergedSubjectDS, "V1", "subject")
```

<b>Combine two activity files</b> into one file: training and test datasets and rename its colnames

```r
mergedYDS <- rbind(YTrainingDS, YTestDS)
setnames(mergedYDS, "V1", "activityNum")
```

<b>Combine two input files</b> into one file: training and test datasets and create the key for it.


```r
mergedDS <- rbind(XTrainingDS, XTestDS)
```

<b>Merge by columns</b> to create the final dataset for analysis before applying the selection criteria


```r
subjectDS <- cbind(mergedSubjectDS, mergedYDS)
dataset <- cbind(subjectDS, mergedDS)
## and create a key on the final merged dataset to be analyzed
setkey(dataset, subject, activityNum) 
```

<b>Read meta-data support files</b>: two files: feature/activity label files and changes its two columns with new names.


```r
featureDS <- fread(file.path(inputDirPath, "features.txt"))
setnames(featureDS, names(featureDS), c("featureID", "featureText"))
activityLabelDS <- fread(file.path(inputDirPath, "activity_labels.txt"))
setnames(activityLabelDS, names(activityLabelDS), c("activityNum", "activityText"))
```

<b>Apply the selection criteria</b> to retrieve only Mean and Standard Deviation rows.Display some data for the verification.


```r
# Extracts only the measurements on the mean or standard deviation for each measurement.
grepStr <- "mean\\(\\)|std\\(\\)"
featureDS <- featureDS[grepl(grepStr, featureText, ignore.case = TRUE)]
dim(featureDS)
```

```
## [1] 66  2
```

```r
# and display the first 6 rows to check the selection via regular expression for a verification
head(featureDS)
```

```
##    featureID       featureText
## 1:         1 tBodyAcc-mean()-X
## 2:         2 tBodyAcc-mean()-Y
## 3:         3 tBodyAcc-mean()-Z
## 4:         4  tBodyAcc-std()-X
## 5:         5  tBodyAcc-std()-Y
## 6:         6  tBodyAcc-std()-Z
```

```r
#
# add a new column with appropriate values used for lookup operation later against the target dataset
#
featureDS$featureVersionID <- featureDS[, paste("V", featureID, sep='')]
dim(featureDS)
```

```
## [1] 66  3
```

```r
colnames(featureDS)
```

```
## [1] "featureID"        "featureText"      "featureVersionID"
```

```r
head(featureDS)
```

```
##    featureID       featureText featureVersionID
## 1:         1 tBodyAcc-mean()-X               V1
## 2:         2 tBodyAcc-mean()-Y               V2
## 3:         3 tBodyAcc-mean()-Z               V3
## 4:         4  tBodyAcc-std()-X               V4
## 5:         5  tBodyAcc-std()-Y               V5
## 6:         6  tBodyAcc-std()-Z               V6
```

Select qualified rows with appropriate labels. A few actions need to be applied: filter, set key, reshape and merge activities... 



```r
criteriaStr <- c(key(dataset), featureDS$featureVersionID)
dim(dataset)
```

```
## [1] 10299   563
```

```r
dataset <- dataset[, criteriaStr, with = FALSE]
dim(dataset)
```

```
## [1] 10299    68
```

```r
dataset <- merge(dataset, activityLabelDS, by = "activityNum", all.x = TRUE)
colnames(dataset)
```

```
##  [1] "activityNum"  "subject"      "V1"           "V2"          
##  [5] "V3"           "V4"           "V5"           "V6"          
##  [9] "V41"          "V42"          "V43"          "V44"         
## [13] "V45"          "V46"          "V81"          "V82"         
## [17] "V83"          "V84"          "V85"          "V86"         
## [21] "V121"         "V122"         "V123"         "V124"        
## [25] "V125"         "V126"         "V161"         "V162"        
## [29] "V163"         "V164"         "V165"         "V166"        
## [33] "V201"         "V202"         "V214"         "V215"        
## [37] "V227"         "V228"         "V240"         "V241"        
## [41] "V253"         "V254"         "V266"         "V267"        
## [45] "V268"         "V269"         "V270"         "V271"        
## [49] "V345"         "V346"         "V347"         "V348"        
## [53] "V349"         "V350"         "V424"         "V425"        
## [57] "V426"         "V427"         "V428"         "V429"        
## [61] "V503"         "V504"         "V516"         "V517"        
## [65] "V529"         "V530"         "V542"         "V543"        
## [69] "activityText"
```

```r
head(dataset)
```

```
##    activityNum subject        V1           V2          V3         V4
## 1:           1       1 0.2820216 -0.037696218 -0.13489730 -0.3282802
## 2:           1       1 0.2558408 -0.064550029 -0.09518634 -0.2292069
## 3:           1       1 0.2548672  0.003814723 -0.12365809 -0.2751579
## 4:           1       1 0.3433705 -0.014446221 -0.16737697 -0.2299235
## 5:           1       1 0.2762397 -0.029638413 -0.14261631 -0.2265769
## 6:           1       1 0.2554682  0.021219063 -0.04894943 -0.2245370
##             V5         V6       V41        V42         V43        V44
## 1: -0.13715339 -0.1890859 0.9453028 -0.2459414 -0.03216478 -0.9840476
## 2:  0.01650608 -0.2603109 0.9411130 -0.2520352 -0.03288345 -0.9839625
## 3:  0.01307987 -0.2843713 0.9463639 -0.2642781 -0.02557507 -0.9628101
## 4:  0.17391077 -0.2133875 0.9524451 -0.2598379 -0.02613106 -0.9811001
## 5:  0.16428792 -0.1225450 0.9471251 -0.2571003 -0.02842261 -0.9769275
## 6:  0.02231294 -0.1131962 0.9457488 -0.2547778 -0.02652145 -0.9853150
##           V45        V46        V81        V82          V83        V84
## 1: -0.9289281 -0.9325598 -0.1564857 -0.1428530 -0.113078690 -0.1837594
## 2: -0.9174993 -0.9490782 -0.2075541  0.3578428 -0.452400930 -0.1083503
## 3: -0.9561309 -0.9719092  0.2016045  0.4170823  0.139078170 -0.1776946
## 4: -0.9643989 -0.9643039  0.3360845 -0.4641436 -0.005025745 -0.1204862
## 5: -0.9885960 -0.9604447 -0.2356234 -0.1117772  0.172654600 -0.1924335
## 6: -0.9801945 -0.9662646  0.1159299  0.2346673  0.361505180 -0.2457770
##            V85        V86         V121        V122        V123       V124
## 1: -0.17046131 -0.6138299 -0.479729520  0.08203403 0.256443090 -0.3235458
## 2: -0.01869285 -0.5475588  0.094091481 -0.30915291 0.086441165 -0.3992529
## 3: -0.02960064 -0.5795071  0.211200570 -0.27290542 0.101986010 -0.4454378
## 4:  0.02865963 -0.5214649  0.096081738 -0.16339425 0.025859464 -0.3604054
## 5:  0.05398133 -0.4693241  0.008742388  0.01166058 0.004174515 -0.3775575
## 6: -0.02056663 -0.4659302 -0.042556600  0.09761780 0.084655454 -0.5108548
##           V125       V126        V161         V162        V163       V164
## 1: -0.14193972 -0.4565980  0.09424803 -0.476210050 -0.14213364 -0.3457161
## 2: -0.08841570 -0.4021575  0.16674262 -0.033796125 -0.08926024 -0.2498919
## 3: -0.06308333 -0.3470558 -0.16322550 -0.005560408 -0.23155479 -0.2642317
## 4:  0.04233342 -0.2761384 -0.05462885  0.340289290 -0.26967159 -0.1020531
## 5:  0.13371503 -0.3081481 -0.07566824  0.171466880  0.13645072 -0.1290674
## 6:  0.02642284 -0.3724244 -0.33244254 -0.406247560  0.23877062 -0.2875010
##          V165       V166        V201       V202        V214       V215
## 1: -0.4867495 -0.4215080 -0.22455962 -0.2379807 -0.22455962 -0.2379807
## 2: -0.4537442 -0.3698131 -0.12650269 -0.2133903 -0.12650269 -0.2133903
## 3: -0.4246765 -0.3425422 -0.16010001 -0.2575711 -0.16010001 -0.2575711
## 4: -0.2434422 -0.3115771 -0.07351308 -0.1951145 -0.07351308 -0.1951145
## 5: -0.1901072 -0.4183491 -0.04949205 -0.2110254 -0.04949205 -0.2110254
## 6: -0.2924124 -0.4825550 -0.07739443 -0.2377672 -0.07739443 -0.2377672
##          V227       V228        V240        V241       V253       V254
## 1: -0.2894243 -0.1650001 -0.03439560 -0.16818626 -0.4661497 -0.4336540
## 2: -0.1385012 -0.1985903 -0.14093823 -0.21605518 -0.3899198 -0.4389841
## 3: -0.1943548 -0.2199436 -0.09459356 -0.29084739 -0.3741507 -0.4180319
## 4: -0.1294801 -0.1739346 -0.04934062 -0.09012390 -0.2364741 -0.2294418
## 5: -0.1598686 -0.1498507 -0.02141046 -0.04463632 -0.2200966 -0.2127722
## 6: -0.2060086 -0.1992724 -0.13887531 -0.16730755 -0.3038356 -0.3744300
##          V266        V267       V268       V269        V270       V271
## 1: -0.2609049 -0.12256680 -0.3312160 -0.3567070 -0.19956719 -0.1777802
## 2: -0.1511153 -0.02904997 -0.2573071 -0.2621973 -0.02385785 -0.3221639
## 3: -0.2304074  0.02542685 -0.3773113 -0.2935223 -0.05769317 -0.2900854
## 4: -0.1513229  0.19526720 -0.3212387 -0.2631256  0.08785532 -0.2169750
## 5: -0.2258036  0.11028848 -0.2048832 -0.2268023  0.11880106 -0.1463515
## 6: -0.2904287  0.05782228 -0.2483574 -0.1999707 -0.06209912 -0.1106583
##          V345        V346       V347       V348         V349       V350
## 1: -0.2104645 -0.26352811 -0.5357091 -0.2282532 -0.124274450 -0.6984362
## 2: -0.1783384 -0.12083878 -0.4989475 -0.1140450  0.027847600 -0.5945946
## 3: -0.1926535 -0.10961071 -0.5256478 -0.2358945 -0.005815575 -0.6328668
## 4: -0.1834189 -0.02597198 -0.4874227 -0.1322793  0.020367181 -0.5528494
## 5: -0.2852402 -0.01110185 -0.4258950 -0.1692272  0.055776797 -0.5102109
## 6: -0.2980468 -0.05172677 -0.4334865 -0.2575384 -0.052800462 -0.4954739
##          V424        V425       V426       V427         V428       V429
## 1: -0.1847807 -0.19802441 -0.3075584 -0.3680772 -0.115047260 -0.5653109
## 2: -0.2045095 -0.24583137 -0.3111780 -0.4613169 -0.009837662 -0.4898550
## 3: -0.3170815 -0.20815880 -0.1857984 -0.4863059  0.009726873 -0.4693567
## 4: -0.1622106  0.02655303 -0.1804687 -0.4234905  0.044652222 -0.3765651
## 5: -0.2371058  0.04721125 -0.2579581 -0.4223431  0.176016240 -0.3885971
## 6: -0.3475347 -0.03515961 -0.3338457 -0.5629958  0.055512057 -0.4428802
##           V503       V504       V516       V517         V529       V530
## 1: -0.16681083 -0.3995829 -0.1540448 -0.1846900 -0.222176040 -0.2736495
## 2: -0.07927762 -0.4230300 -0.1784456 -0.2306563 -0.268279820 -0.3146234
## 3: -0.15631258 -0.4368583 -0.1494380 -0.3212563 -0.308670720 -0.4014002
## 4: -0.10437689 -0.3762153 -0.1322222 -0.2326118 -0.060131490 -0.2746461
## 5: -0.12319532 -0.3878596 -0.1160875 -0.2010365 -0.003821466 -0.2462486
## 6: -0.20002501 -0.3781722 -0.1590210 -0.2578159 -0.174531260 -0.3073559
##          V542       V543 activityText
## 1: -0.4318317 -0.4763701      WALKING
## 2: -0.4281859 -0.4928844      WALKING
## 3: -0.4010383 -0.4819242      WALKING
## 4: -0.2176688 -0.2992263      WALKING
## 5: -0.1875509 -0.3003380      WALKING
## 6: -0.3383588 -0.4650149      WALKING
```

```r
setkey(dataset, subject, activityNum, activityText)
dataset <- data.table(melt(dataset, key(dataset), variable.name = "featureVersionID"))
dataset <- merge(dataset, featureDS[, list(featureID, featureVersionID, featureText)], by = "featureVersionID", all.x = TRUE)

# create two new factor variables: activity and feature from two data frame variables

dataset$activity <- factor(dataset$activityText)
dataset$feature <- factor(dataset$featureText)
```

<b>Create new matrix</b> with variables derived from the Feature Column so we can be ready for the final tidy
output dataset


```r
grepFunct <- function(regex) {
  grepl(regex, dataset$feature)
}
## Features with 1 category
n <- 2
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepFunct("^t"), grepFunct("^f")), ncol = nrow(y))
dataset$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))
x <- matrix(c(grepFunct("Acc"), grepFunct("Gyro")), ncol = nrow(y))
dataset$featInstrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
x <- matrix(c(grepFunct("BodyAcc"), grepFunct("GravityAcc")), ncol = nrow(y))
dataset$featAcceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
x <- matrix(c(grepFunct("mean()"), grepFunct("std()")), ncol = nrow(y))
dataset$featVariable <- factor(x %*% y, labels = c("Mean", "SD"))
## Features with 1 category
dataset$featJerk <- factor(grepFunct("Jerk"), labels = c(NA, "Jerk"))
dataset$featMagnitude <- factor(grepFunct("Mag"), labels = c(NA, "Magnitude"))
## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow = n) 
x <- matrix(c(grepFunct("-X"), grepFunct("-Y"), grepFunct("-Z")), ncol = nrow(y))
dataset$featAxis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))
head(dataset)
```

```
##    featureVersionID subject activityNum activityText     value featureID
## 1:               V1       1           1      WALKING 0.2820216         1
## 2:               V1       1           1      WALKING 0.2558408         1
## 3:               V1       1           1      WALKING 0.2548672         1
## 4:               V1       1           1      WALKING 0.3433705         1
## 5:               V1       1           1      WALKING 0.2762397         1
## 6:               V1       1           1      WALKING 0.2554682         1
##          featureText activity           feature featDomain featInstrument
## 1: tBodyAcc-mean()-X  WALKING tBodyAcc-mean()-X       Time  Accelerometer
## 2: tBodyAcc-mean()-X  WALKING tBodyAcc-mean()-X       Time  Accelerometer
## 3: tBodyAcc-mean()-X  WALKING tBodyAcc-mean()-X       Time  Accelerometer
## 4: tBodyAcc-mean()-X  WALKING tBodyAcc-mean()-X       Time  Accelerometer
## 5: tBodyAcc-mean()-X  WALKING tBodyAcc-mean()-X       Time  Accelerometer
## 6: tBodyAcc-mean()-X  WALKING tBodyAcc-mean()-X       Time  Accelerometer
##    featAcceleration featVariable featJerk featMagnitude featAxis
## 1:             Body         Mean       NA            NA        X
## 2:             Body         Mean       NA            NA        X
## 3:             Body         Mean       NA            NA        X
## 4:             Body         Mean       NA            NA        X
## 5:             Body         Mean       NA            NA        X
## 6:             Body         Mean       NA            NA        X
```

```r
colnames(dataset)
```

```
##  [1] "featureVersionID" "subject"          "activityNum"     
##  [4] "activityText"     "value"            "featureID"       
##  [7] "featureText"      "activity"         "feature"         
## [10] "featDomain"       "featInstrument"   "featAcceleration"
## [13] "featVariable"     "featJerk"         "featMagnitude"   
## [16] "featAxis"
```

<b>Create the final tidy dataset</b>


```r
# about to create the final tidy dataset
setkey(dataset, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
datasetTidy <- dataset[, list(count = .N, average = mean(value)), by = key(dataset)]
dim(datasetTidy)
```

```
## [1] 11880    11
```

```r
colnames(datasetTidy)
```

```
##  [1] "subject"          "activity"         "featDomain"      
##  [4] "featAcceleration" "featInstrument"   "featJerk"        
##  [7] "featMagnitude"    "featVariable"     "featAxis"        
## [10] "count"            "average"
```

```r
head(datasetTidy)
```

```
##    subject activity featDomain featAcceleration featInstrument featJerk
## 1:       1   LAYING       Time               NA      Gyroscope       NA
## 2:       1   LAYING       Time               NA      Gyroscope       NA
## 3:       1   LAYING       Time               NA      Gyroscope       NA
## 4:       1   LAYING       Time               NA      Gyroscope       NA
## 5:       1   LAYING       Time               NA      Gyroscope       NA
## 6:       1   LAYING       Time               NA      Gyroscope       NA
##    featMagnitude featVariable featAxis count     average
## 1:            NA         Mean        X    50 -0.01655309
## 2:            NA         Mean        Y    50 -0.06448612
## 3:            NA         Mean        Z    50  0.14868944
## 4:            NA           SD        X    50 -0.87354387
## 5:            NA           SD        Y    50 -0.95109044
## 6:            NA           SD        Z    50 -0.90828466
```

<b>Generate the code book</b>


```r
knit("mkcodebook.Rmd", output="codebook.md", encoding="ISO8859-1", quiet=TRUE)
```

```
## [1] "codebook.md"
```

```r
markdownToHTML("codebook.md", "codebook.html")
```
