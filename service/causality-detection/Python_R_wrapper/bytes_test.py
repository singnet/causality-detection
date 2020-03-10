import pandas as pd
import io

# CSV to String
df = pd.read_csv('./natural_data2.csv')
str_csv = df.to_csv()

# String to CSV
new_df = pd.read_csv(io.StringIO(str_csv))

