import grpc

# import the generated classes
import service.service_spec.causality_detection_pb2_grpc as grpc_bt_grpc
import service.service_spec.causality_detection_pb2 as grpc_bt_pb2

from service import registry
import pandas as pd
import io

if __name__ == "__main__":

    try:
        # open a gRPC channel
        endpoint = "localhost:{}".format(registry["causality_detection_service"]["grpc"])
        channel = grpc.insecure_channel("{}".format(endpoint))
        print("Opened channel")

        # setting parameters
        grpc_method = "detect_causality"

        data = pd.read_csv('./Python_R_wrapper/natural_data2.csv').to_csv()
        start = ""
        end = ""
        input_features = "Ozone, WMGHG"
        output_feature = "Temperature"
        lags = 3
        modelling_type = ""
        list_subcausalities = True

        # create a stub (client)
        stub = grpc_bt_grpc.CausalityDetectionStub(channel)
        print("Stub created.")

        print("Data type: {}".format(type(data)))

        # create a valid request message
        request = grpc_bt_pb2.CausalityDetectionRequest(data=data,
                                                        start=start,
                                                        end=end,
                                                        input_features=input_features,
                                                        output_feature=output_feature,
                                                        lags=lags,
                                                        modelling_type=modelling_type,
                                                        list_subcausalities=list_subcausalities)
        # make the call
        print("Calling detect causality from test script!")
        output = stub.detect_causality(request)
        print("Response received!")

        # et voilà
        if output.response:
            print('Received response: {}'.format(output.response))
            print('Received message: {}'.format(output.message))
            print("Service completed!")
            exit(0)
        else:
            print("Service failed! No data received.")
            exit(1)

    except Exception as e:
        print(e)
        exit(1)
