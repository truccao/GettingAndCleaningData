---
title: "Make the code book"
output: html_document
---

<b>Databaset Attribute Definition</b>

Column Name|Column Description
-----------|------------------
subject|ID the subject who performed the activity for each window sample. Its range is from 1 to 30.
activity|Activity name
featDomain|Time domain signal or frequency domain signal (Time or Freq)
featInstrument|Measuring instrument (Accelerometer or Gyroscope)
featAcceleration|Acceleration signal (Body or Gravity)
featVariable|Variable (Mean or Standard Deviation)
featJerk|Jerk signal
featMagnitude|Magnitude of the signals calculated using the Euclidean norm
featAxis|3-axial signals in the X, Y and Z directions (X, Y, or Z)
featCount|Count of data points used to compute average
featAverage|Average of each variable for each activity and each subject

<b>Dataset Name</b> 
<br>
 - HumanActivityRecognitionUsingSmartphones.txt
 
<b>Generate the final tidy output file</b>
<br>
 - write.table(datasetTidy, "HumanActivityRecognitionUsingSmartphones.txt", quote=FALSE, sep="\t", row.names=FALSE)
 
 
