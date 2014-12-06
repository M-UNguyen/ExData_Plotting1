library(data.table)
library(dplyr)

# plot2.R assumes that the "Individual household electric power
# consumption Data Set" has been downloaded, unzipped, and
# placed in the same working directory as the R code.
#
fileNm <- "household_power_consumption.txt"

# STEP 1:  Load in the data to be plotted, from the dates
# 2007-02-01 to 2007-02-02.
#
# Instead of reading in the entire data set, then subsetting,
# first read in just the Date column to find the indices of the
# rows corresponding to the date interval.  Use fread for faster
# speed.
#
df1 <- fread(fileNm, header = TRUE, sep = ";", select = "Date")
idx1 <- which.max(df1$Date == "1/2/2007")
idx2 <- which.max(df1$Date == "3/2/2007")

# Use the indices to skip to the start of data for 2007-02-01
# (row 66637) and read the expected number of records (2880).
#  
colNames <- read.table(fileNm, sep = ";", as.is = TRUE, nrows = 1)
df2 <- read.table(fileNm, header = FALSE,
		sep = ";",
		col.names = colNames,
		colClasses = c(rep("character", 2), rep("numeric", 7)),
		na.strings = "?",
		skip = idx1, nrows = idx2-idx1,
		comment.char = "")

# Add a concatenated date & time field and convert it to a POSIXct
# object.
#
df2 <- mutate(df2, DateTime = paste(Date, Time))
df2$DateTime <- strptime(df2$DateTime, format = "%d/%m/%Y %H:%M:%S")


####################################################################
# STEP 2:  Create a line graph of Global_active_power on the y-axis
# against date & time on the x-axis; save it to plot2.png.
#
png("plot2.png")
plot(df2$DateTime, df2$Global_active_power, type = "n",
	xlab = "", ylab = "Global Active Power (kilowatts)")
lines(df2$DateTime, df2$Global_active_power, type = "l")
dev.off()

