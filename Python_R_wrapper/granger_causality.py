import rpy2.rinterface
import rpy2.robjects as robjects
from rpy2.robjects.packages import importr
from rpy2.robjects import pandas2ri
import pandas as pd
utils = importr("utils")
d = {'Issue at importr': 'Issue at importr', 'Issue at importr': 'Issue at importr'}
utils.install_packages('vars',repos="https://cloud.r-project.org/")
try:
    thatpackage = importr('vars', robject_translations = d)
except:
    try:
        thatpackage = importr('vars', robject_translations = d, lib_loc = "/usr/lib64/R/library")
    except:
        thatpackage = importr('vars', robject_translations = d, lib_loc = "/usr/share/R/library")
import rpy2.robjects as ro
from rpy2.robjects.conversion import localconverter
from rpy2.robjects.packages import importr
from rpy2.robjects import pandas2ri
pandas2ri.activate()
        

def granger_causality(data,cols,y_var,lags,our_type,list_subcausalities=False):
    y_subset = data[y_var]
    pandas2ri.activate()
    data = pandas2ri.py2ri(data)
    ### We define the functions;
    robjects.r('''
      is.installed <- function(mypkg){
        is.element(mypkg, installed.packages()[,1])
      } 

      # check if package "gtools" is installed
      if (!is.installed("gtools")){
        install.packages("gtools", INSTALL_opts = '--no-lock', repos='https://cloud.r-project.org')
      }
      if (!is.installed("vars")){
        install.packages("vars", INSTALL_opts = '--no-lock', repos='https://cloud.r-project.org')
      }      
         library("gtools")
         library("vars")
         for (k in .libPaths()){
           k <- paste0(k,"/00LOCK")
           unlink(k, recursive = TRUE)
         }
         get_p_value <- function(data,lags,y_values,causes,our_type){
         data <- as.data.frame(data)
         mycols <- c(as.character(unlist(causes)))
         mydata <- data[c(as.character(unlist(causes)))]
         mydata <- as.data.frame(mydata)
         mydata <- cbind(Temperatures = y_values,mydata)
         var.2c <- VAR(mydata, p = lags, type = our_type) ### In this case, we are using trended Granger causality
         my_vcov <- vcovHC(var.2c)
         mycause <- causality(var.2c, cause = mycols)
         return(c(mycause$Granger$p.value))
    }
    
    permuts <- function(data,order,y,columns,our_type){
      list_perms <- do.call("c", lapply(seq_along(columns), function(i) combn(columns, i, FUN = list)))
      d <- data.frame(x = NA, y = 1:length(list_perms))
      i <- 1
      columns <- unlist(columns)
      while (i<=length(list_perms)){
        myp <- get_p_value(data,order,y,list_perms[i][[1]],our_type = our_type)
        d[i,] <- c(toString(unlist(list_perms[i][[1]])),as.numeric(myp))
        i <- i + 1
      }
      colnames(d) <- c("Sets of variables","p-value")
      d$`p-value` <- as.numeric(d$`p-value`)
      return(d)
      #return(.libPaths())
      #return(unlist(list_perms[i-1][[1]]))
        }
            ''')

    r_f = robjects.globalenv['get_p_value']
    permuts = robjects.globalenv['permuts']
    robjects.r.library("vars")
    our_causes = robjects.r('as.data.frame')(cols)
    if list_subcausalities==True:
        mydf = permuts(data,lags,robjects.Vector(y_subset),our_causes,our_type)
        return(mydf)
    
    return(r_f(data,lags,robjects.Vector(y_subset),our_causes,our_type))
    
