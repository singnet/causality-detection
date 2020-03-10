mydata <- read.csv("natural_data.csv")
### cut after 1880
mydata <- mydata[which(mydata$Year>=1880),]
## read in the packages
require(gtools)
require(vars)
get_p_value <- function(data,lags,y_values,causes,our_type){
  data <- as.data.frame(data)
  mycols <- as.character(unlist(c(causes)))
  mydata <- data[mycols]
  mydata <- as.data.frame(mydata)
  mydata <- cbind(Temperatures = y_values,mydata)
  var.2c <- VAR(mydata, p = lags, type = our_type)
  my_vcov <- vcovHC(var.2c)
  mycause <- causality(var.2c, cause = mycols)
  return(c(mycause$Granger$p.value))
}
#### Natural:
natural <- cbind(mydata$Solar,mydata$Orbital,mydata$StratAer)
natural <- as.data.frame(natural)
colnames(natural) <- c("Solar","Orbital","StratAer")
get_p_value(natural,3,mydata$Ocean,c("Solar","Orbital","StratAer"),"trend")
