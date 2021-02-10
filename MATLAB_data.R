dir <- getwd()
target_dir <- "/Users/rebeccawilder/Desktop/CMR"
setwd(target_dir)

my_data <- read.csv(file= "R_data_02072021.csv")
my_data <- data.frame(my_data)

my_data
data_names <- c("subject", "session", "list", "rec_itemnos", "rt", "sp", "op", "lag", "ffr")
colnames(my_data) <- data_names


rt= my_data$rt
op= my_data$op
ffr= my_data$ffr

op<- op[1:length(rt)]

lag= my_data$lag
ffr_out_put= op[ffr==TRUE]
#plot hist for rt
hist(rt,breaks = 100,probability = TRUE, main= "Histogram of Response Times")
lines(

#plot hist for lag
hist(lag, breaks= 100, probability= TRUE, xlab= "N Intervening Items", main= "Intervening Items Between Presentation and IFR")

#plot hist for 'was it ffr?'
hist(ffr_out_put, breaks= 100, probability= TRUE, main= "IFR Output Positions That Were FFR", xlab= "Output")


             