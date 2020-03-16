from granger_causality import granger_causality
import pandas as pd
import numpy as np

our_data = pd.read_csv("natural_data2.csv")
our_data = our_data[np.where(our_data['Year']==1880)[0][0]:]

print(granger_causality(our_data,['Ozone','WMGHG','Land_Use','Orbital'],'Temperature',lags=3,our_type='trend',list_subcausalities=True))
