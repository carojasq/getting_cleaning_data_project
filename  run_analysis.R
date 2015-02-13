download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "data.zip", method="curl")
unzip("data.zip")
# Load separate data, I have ran sed -i "s/  / /g" X_test.txt and sed -i "s/  / /g" X_train.txt to fix double spaces
test_df_x <- read.csv("UCI HAR Dataset/test/X_test.txt", stringsAsFactors=FALSE, header=FALSE, sep = " ")
test_df_y <- read.csv("UCI HAR Dataset/test/y_test.txt", stringsAsFactors=FALSE, header=FALSE)
test_df_subject <- read.csv("UCI HAR Dataset/test/subject_test.txt", stringsAsFactors=FALSE, header=FALSE)
train_df_x <- read.csv("UCI HAR Dataset/train/X_train.txt", stringsAsFactors=FALSE, header=FALSE, sep = " ")
train_df_y <- read.csv("UCI HAR Dataset/train/y_train.txt", stringsAsFactors=FALSE, header=FALSE)
train_df_subject <- read.csv("UCI HAR Dataset/train/subject_train.txt", stringsAsFactors=FALSE, header=FALSE)
#Load col names
#Fictial separator "*"
col_names <- read.csv("UCI HAR Dataset/features.txt", stringsAsFactors=FALSE, header=FALSE, sep="*")[, 1]
#Delete numbers from colum names
fixed_col_names <- gsub("^[0-9]+ ", "", col_names)
names(test_df_x) <- fixed_col_names
names(train_df_x) <- fixed_col_names
# Select cols by mean and std
to_preserve <- fixed_col_names[grep("mean\\(\\)|std\\(\\)", fixed_col_names)]
test_df_x <- test_df_x[, to_preserve]
train_df_x <- train_df_x[, to_preserve]
# Merge datasets
test_df <- cbind(test_df_subject, test_df_y, test_df_x )
names(test_df)[1] <- "subject"
names(test_df)[2] <- "activities"
train_df <- cbind(train_df_subject, train_df_y,  train_df_x )
names(train_df)[1] <- "subject"
names(train_df)[2] <- "activities"
merged_df <- rbind(test_df, train_df)

# Define labels for activities (FACTORS)
merged_df$activities <- factor(merged_df$activities, levels = c(1,2,3,4,5,6), labels = c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))
merged_df$subject <- factor(merged_df$subject, unique(merged_df$subject))

# Descriptive col names 
names(merged_df) <- gsub("-Z", "Axis Z", names(merged_df))
names(merged_df) <- gsub("-X", "Axis X", names(merged_df))
names(merged_df) <- gsub("-Y", "Axis Y", names(merged_df))
names(merged_df) <- gsub("Acc", "Acceleration ", names(merged_df))
names(merged_df) <- gsub("Body", "Body  ", names(merged_df))
names(merged_df) <- gsub("Jerk", "Jerk  ", names(merged_df))
names(merged_df) <- gsub("Mag", "Magnitude  ", names(merged_df))
names(merged_df) <- gsub("^t", "Time  ", names(merged_df))
names(merged_df) <- gsub("^f", "Frequency  ", names(merged_df))
names(merged_df) <- gsub(" -", " ", names(merged_df))
names(merged_df) <- gsub("\\(\\)", " ", names(merged_df))

#Make and write the final table
library(plyr)
sumarized <- merged_df %>% group_by(subject, activities) %>% summarise_each(funs(mean))
write.table(sumarized, "tidy_data.txt")

