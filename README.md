# Causality detection

This is a project regarding Granger causality. Relevant code can be found here.

## Getting Started

Here is the code to perform Granger causality, be it single or multi variate. A general description of the mathematical model can be found here: https://en.wikipedia.org/wiki/Granger_causality. For more detailed reading, one can refer to original paper by Granger (1969)  available here: https://www.jstor.org/stable/1912791?origin=crossref&seq=1
This code does multivariate Granger causality as well. This means that we find if multitude of variables significantly cause our y variable.

### Prerequisites

One can run this in standard R or RStudio. Required packages: vars, gtools. The code also works in Python.


## Built With

RStudio, Python


Running the tests

CausalityDetectionRequest(data=data,
                                                        start=start,
                                                        end=end,
                                                        input_features=input_features,
                                                        output_feature=output_feature,
                                                        lags=lags,
                                                        modelling_type=modelling_type)
We insert data, decide in which time period we start and end, which features are causing the output feature, the output feature (y variable), number of lags and possible modeling type. There are 4 modeling types:
- "both": When we use both constant and trend in the model.
- "const": When we use constant only in the model.
- "trend": When we use trend only in the model.
- "none": When we use neither trend nor constant in the model.

We prepared test_service.py as an example service. The dataset we use there is from CMIP5 data. There, we make a test how Ozone and WMGHG (well-mixed Greenhouse gasses) affect temperature for the duration of the whole dataset (1880-2012) looking for 3 periods (years) at the time.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


