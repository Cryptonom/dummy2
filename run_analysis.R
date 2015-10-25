# run_analysis.R
#
# Does the following:
#   1) Merges the training and the test sets to create one data set.
#   2) Extracts only the measurements on the mean and standard deviation 
#       for each measurement. 
#   3) Uses descriptive activity names to name the activities in the data set
#   4) Appropriately labels the data set with descriptive variable names. 
#   5) From the data set in step 4, creates a second, independent tidy data set 
#       with the average of each variable for each activity and each subject.
# 



# if not priviously installed
# install.packages("dplyr")
# library(dplyr)
# library(stringr)


# Reading the data
xTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")

xTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")

# Reading the subjects
subjTest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
subjTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")


# Reading the names of the variables (i. e. features)
feat <- read.table("./data/UCI HAR Dataset/features.txt")

# Reading the names of the activities
activityNames <- read.table("./data/UCI HAR Dataset/activity_labels.txt")



#  1) 'Merge (or better combine) the training and the test sets' 
#     to create one data set (subjects and activities added later):
values <- rbind(xTrain, xTest)
activities <- rbind(yTrain, yTest)
subjects <- rbind(subjTrain, subjTest)


# 4)  'Appropriately labels the data set with descriptive variable names'
#     I provide the labels in advance. Not needed names are omitted together with
#     not needded variables later.
#     dlpyr not needed, a new name vector works as well
names(values)<- feat[[2]]


#  2) 'Extracts only the measurements on the mean and standard deviation 
#       for each measurement'
#  Using str_detect (Thanks to Forum) as regex is not known by me, yet


# I don't know if "fBodyGyro-meanFreq()-X" shoud be part of the result set
# I couldn't figure out form the exercise description 
# If it should be exclude it would be: 
#    isMeanFeature2 <- str_detect(feat[[2]], "mean") & !str_detect(feat[[2]], "Freq")
isMeanFeature2 <- str_detect(feat[[2]], "mean")  
isStdFeature <- str_detect(feat[[2]], "std")

# Restrict values to what is a Mean-Feature or a Std-Feature
values <- values[isMeanFeature2 | isStdFeature]


# Add a column with acitvity names matching the activity number
names(activities)<-"actNo"
activities <- mutate(activities, actNames = activityNames[[2]][actNo])


#  1) 'Merge (or better combine) the training and the test sets' 
#     Adding the activities and subjects and providing names for columns:
values <- cbind(subjects, activities["actNames"], values)
names(values)[1:2] <- c("subject", "activity")


# Split in order to get values for each subject/acitvity comnination
subjectsActivities <- split(values[,-c(1,2)], list(values$subject, values$activity))
# get the means for each subject/activity combination
subjectsActivitiesMeans <- sapply(subjectActivity, colMeans)
# transpose result as I want the original variables to be the new variables (activity / subject is row)
subjectsActivitiesMeans <- t(subjectsActivitiesMeans)

write.table(subjectsActivitiesMeans, file="project_Frank.txt", row.name=FALSE)

