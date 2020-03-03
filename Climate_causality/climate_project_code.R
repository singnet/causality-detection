'''

MIT License

Copyright (c) 2019 nejc9921

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

'''
### Read data in:
mydata <- read.csv("natural_data.csv")
### cut after 1880
mydata <- mydata[which(mydata$Year>=1880),]
## read in the packages
require(gtools)
require(vars)
type_of_GC <- "trend"
### function where we get a p-value of the test.
### we have the data as an input (data frame, number of lags, values of endogenous variable and which columns are the causes).
get_p_value <- function(data,lags,y_values,causes,our_type){
  mydata <- cbind(Temperatures = y_values,data)
  var.2c <<- VAR(mydata, p = lags, type = our_type) ### In this case, we are using trended Granger causality
  my_vcov <- vcovHC(var.2c)
  mycause <- causality(var.2c, cause = causes)
  return(c(mycause$Granger$p.value))
}

#### Natural forcings:
natural <- cbind(mydata$Solar,mydata$Orbital,mydata$StratAer)
natural <- as.data.frame(natural)
### We make sure we have the right column names.
colnames(natural) <- c("Solar","Orbital","StratAer")
### We make a GC on all three natural forcings.
get_p_value(natural,3,mydata$Temperature,c("Solar","Orbital","StratAer"),our_type = type_of_GC)

## We define function that makes a subset and performs Granger causality only on certain subset.
### Input is all data (data), order is the number of lags that we use, y is the name of the column of the endogenous variable
### and columns is which variables we take in Granger causality.
smaller_tests <- function(data,order,y,columns,our_type){
  ### We make a subset of data.
  sub_data <- data[c(columns)]
  sub_data <- as.data.frame(sub_data)
  get_p_value(sub_data,order,data[y],columns,our_type)
  
}
### Now we make smaller tests for smaller subsets of factors.
smaller_tests(mydata,3,"Temperature",c("Solar","Orbital"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Solar","StratAer"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Orbital","StratAer"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Solar"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Orbital"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("StratAer"),our_type = type_of_GC)

### Do the same for ocean:
get_p_value(natural,3,mydata$Ocean,c("Solar","Orbital","StratAer"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Solar","Orbital"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Solar","StratAer"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Orbital","StratAer"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Solar"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Orbital"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("StratAer"),our_type = type_of_GC)


###
### Non-natural:
manmade <- cbind(mydata$WMGHG,mydata$Land_Use)
### Add all observed (in our analysis) 
manmade <- cbind(manmade,mydata$TropAerDir)
manmade <- cbind(manmade,mydata$Ozone,mydata$TropAerInd)
manmade <- as.data.frame(manmade)
### We name the forcings (or the columns there)
colnames(manmade) <- c("WMGHG","Land_Use","TropAerDir","Ozone","TropAerInd")
### We make a joint test for all forcings at the same time.
get_p_value(manmade,3,mydata$Temperature,c("WMGHG","Land_Use","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)

### We look at the correlations and add write the result to csv.
small_dt <- mydata[c("WMGHG","Land_Use","TropAerDir","Ozone","TropAerInd")]
all_cors <- cor(small_dt)
write.csv(all_cors,"correlations.csv")

### Manmade, testing less variables:
smaller_tests(mydata,3,"Temperature",c("WMGHG","Land_Use","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Land_Use","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","Land_Use","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","Land_Use","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","Land_Use","TropAerDir"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","Land_Use","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","Land_Use","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Land_Use","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Land_Use","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Land_Use","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","Land_Use"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","TropAerDir"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Land_Use","TropAerDir"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Land_Use","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Land_Use","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("WMGHG"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Land_Use"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("TropAerDir"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Temperature",c("TropAerInd"),our_type = type_of_GC)



### Now we do he same tests for ocean temperatures as well:
get_p_value(manmade,3,mydata$Ocean,c("WMGHG","Land_Use","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","Land_Use","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Land_Use","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)

smaller_tests(mydata,3,"Ocean",c("WMGHG","Land_Use","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Land_Use","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","Land_Use","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","Land_Use","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","Land_Use","TropAerDir"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","Land_Use","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","Land_Use","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Land_Use","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Land_Use","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Land_Use","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","Land_Use"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","TropAerDir"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Land_Use","TropAerDir"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Land_Use","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Land_Use","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("WMGHG"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Land_Use"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("TropAerDir"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("Ozone"),our_type = type_of_GC)
smaller_tests(mydata,3,"Ocean",c("TropAerInd"),our_type = type_of_GC)


### and now the shorter time span, we only look data from 1958 and later:
shorter_mydata <- mydata[mydata$Year>1957,]
### Non-natural:
manmade <- cbind(shorter_mydata$WMGHG,shorter_mydata$Land_Use)
### We do similar thing as we did before on longer time frame.
manmade <- cbind(manmade,shorter_mydata$TropAerDir)
manmade <- cbind(manmade,shorter_mydata$Ozone,shorter_mydata$TropAerInd)
manmade <- as.data.frame(manmade)
colnames(manmade) <- c("WMGHG","Land_Use","TropAerDir","Ozone","TropAerInd")
### And now getting p-values, just like before.
get_p_value(manmade,3,shorter_mydata$Temperature,c("WMGHG","Land_Use","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","Land_Use","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("Land_Use","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","Land_Use","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","Land_Use","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","Land_Use","TropAerDir"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","Land_Use","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","Land_Use","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("Land_Use","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("Land_Use","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("Land_Use","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","Land_Use"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","TropAerDir"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("Land_Use","TropAerDir"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("Land_Use","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("Land_Use","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("WMGHG"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("Land_Use"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("TropAerDir"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Temperature",c("TropAerInd"),our_type = type_of_GC)


### Ocean
get_p_value(manmade,3,shorter_mydata$Ocean,c("WMGHG","Land_Use","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","Land_Use","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("Land_Use","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","Land_Use","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","Land_Use","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","Land_Use","TropAerDir"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","Land_Use","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","Land_Use","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("Land_Use","TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("Land_Use","TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("Land_Use","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("TropAerDir","Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","Land_Use"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","TropAerDir"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("Land_Use","TropAerDir"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("Land_Use","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("Land_Use","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("TropAerDir","Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("TropAerDir","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("Ozone","TropAerInd"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("WMGHG"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("Land_Use"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("TropAerDir"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("Ozone"),our_type = type_of_GC)
smaller_tests(shorter_mydata,3,"Ocean",c("TropAerInd"),our_type = type_of_GC)



### Natural causes:
#### Natural:
natural <- cbind(shorter_mydata$Solar,shorter_mydata$Orbital,shorter_mydata$StratAer)
natural <- as.data.frame(natural)
colnames(natural) <- c("Solar","Orbital","StratAer")
get_p_value(natural,3,shorter_mydata$Temperature,c("Solar","Orbital","StratAer"),our_type = type_of_GC)



### Check smaller subsets with less variables  (for natural factors);
natural1 <- cbind(shorter_mydata$Temperature,shorter_mydata$Solar,shorter_mydata$Orbital,shorter_mydata$StratAer)
natural1 <- as.data.frame(natural1)
colnames(natural1) <- c("Temperature","Solar","Orbital","StratAer")
smaller_tests(natural1,3,"Temperature",c("Solar","Orbital","StratAer"),our_type = type_of_GC)
smaller_tests(natural1,3,"Temperature",c("Solar","Orbital"),our_type = type_of_GC)
smaller_tests(natural1,3,"Temperature",c("Solar","StratAer"),our_type = type_of_GC)
smaller_tests(natural1,3,"Temperature",c("Orbital","StratAer"),our_type = type_of_GC)
smaller_tests(natural1,3,"Temperature",c("Solar"),our_type = type_of_GC)
smaller_tests(natural1,3,"Temperature",c("Orbital"),our_type = type_of_GC)
smaller_tests(natural1,3,"Temperature",c("StratAer"),our_type = type_of_GC)

## Ocean
natural1 <- cbind(shorter_mydata$Ocean,shorter_mydata$Solar,shorter_mydata$Orbital,shorter_mydata$StratAer)
natural1 <- as.data.frame(natural1)
colnames(natural1) <- c("Ocean","Solar","Orbital","StratAer")
smaller_tests(natural1,3,"Ocean",c("Solar","Orbital","StratAer"),our_type = type_of_GC)
smaller_tests(natural1,3,"Ocean",c("Solar","Orbital"),our_type = type_of_GC)
smaller_tests(natural1,3,"Ocean",c("Solar","StratAer"),our_type = type_of_GC)
smaller_tests(natural1,3,"Ocean",c("Orbital","StratAer"),our_type = type_of_GC)
smaller_tests(natural1,3,"Ocean",c("Solar"),our_type = type_of_GC)
smaller_tests(natural1,3,"Ocean",c("Orbital"),our_type = type_of_GC)
smaller_tests(natural1,3,"Ocean",c("StratAer"),our_type = type_of_GC)



