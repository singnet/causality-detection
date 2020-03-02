import rpy2.rinterface
import rpy2.robjects as robjects
from rpy2.robjects.packages import importr

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

        

def granger_causality(data,cols,y_var,lags,our_type):
    data = pd.read_csv(data)
    y_subset = data[y_var]
    pandas2ri.activate()
    #data = pandas2ri.ri2py(data)

    #with localconverter(ro.default_converter + pandas2ri.converter):
    #    data = ro.conversion.py2rpy(data)


    data = pandas2ri.py2ri(data)
    #r = robjects.r
    #x = robjects.IntVector(range(10))
    ### We define the functions;
    robjects.r('''
            require(gtools)
            require(vars)
            get_p_value <- function(data,lags,y_values,causes,our_type){
            data <- as.data.frame(data)
            mycols <- as.character(unlist(c(causes)))
            mydata <- data[mycols]
            mydata <- as.data.frame(mydata)
            mydata <- cbind(Temperatures = y_values,mydata)
            var.2c <- VAR(mydata, p = lags, type = our_type) ### In this case, we are using trended Granger causality
            my_vcov <- vcovHC(var.2c)
            mycause <- causality(var.2c, cause = mycols)
            return(c(mycause$Granger$p.value))
    }
            ''')


    r_f = robjects.globalenv['get_p_value']
    
    robjects.r.library("vars")
    #our_causes = pandas2ri.ri2py(robjects.r('as.data.frame')(cols))
    our_causes = robjects.r('as.data.frame')(cols)
    return(r_f(data,lags,robjects.Vector(y_subset),our_causes,our_type))
    #return(robjects.r('as.data.frame')(cols))
