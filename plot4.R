library(data.table)
library(dplyr)

# plot4.R assumes that the "Individual household electric power
# consumption" data set has been downloaded, unzipped, and
# placed in the same working directory as the R code.
#
fileNm <- "household_power_consumption.txt"

# STEP 1:  Load in the data to be plotted, from the dates
# 2007-02-01 to 2007-02-02.
#
# Instead of reading in the entire data set, then subsetting,
# first read in just the Date column and find the indices of the
# rows corresponding to the date interval.  Use fread for faster
# speed.
#
df1 <- fread(fileNm, header = TRUE, sep = ";", select = "Date")
idx1 <- which.max(df1$Date == "1/2/2007")
idx2 <- which.max(df1$Date == "3/2/2007")

# Use these indices to skip to the start of data for 2007-02-01
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
# STEP 2:  Create a 2x2 pane, saved to plot4.png, that combines the
# following plots:
# - top-left, a line graph of Global_active_power on the y-axis
# against date & time on the x-axis;
# - top-right, a line graph of Voltage on the y-axis against date
# & time on the x-axis;
# - bottom-left, a line graph, with legend, of the 3 Sub_metering
# measurements on the y-axis against date & time on the x-axis;
# - bottom-right, a line graph of Global_reactive_power on the
# y-axis against date & time on the x-axis. 
#
png("plot4.png")
par(mfrow = c(2,2))

plot(df2$DateTime, df2$Global_active_power, type = "n",
	xlab = "", ylab = "Global Active Power")
lines(df2$DateTime, df2$Global_active_power, type = "l")

plot(df2$DateTime, df2$Voltage, type = "n",
	xlab = "datetime", ylab = "Voltage")
lines(df2$DateTime, df2$Voltage, type = "l")

plot(df2$DateTime, df2$Sub_metering_1, type = "n",
		xlab = "", ylab = "Energy sub metering")
lines(df2$DateTime, df2$Sub_metering_1, type = "l")
lines(df2$DateTime, df2$Sub_metering_2, type = "l", col = "blue")
lines(df2$DateTime, df2$Sub_metering_3, type = "l", col = "red")
legend(x = "topright", bty = "n",
		legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"),
		lty = 1, col = c("black", "red", "blue"))

plot(df2$DateTime, df2$Global_reactive_power, type = "n",
	xlab = "datetime", ylab = "Global_reactive_power")
lines(df2$DateTime, df2$Global_reactive_power, type = "l")

dev.off()

