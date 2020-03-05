import logging
import grpc
import service
import service.service_spec.causality_detection_pb2_grpc as grpc_bt_grpc
from service.service_spec.causality_detection_pb2 import Result
import concurrent.futures as futures
import sys
import os
from urllib.error import HTTPError
from multiprocessing import Pool
from granger_causality import granger_causality
import pandas as pd
import numpy as np


logging.basicConfig(
    level=10, format="%(asctime)s - [%(levelname)8s] - %(name)s - %(message)s"
)
log = logging.getLogger("causality_detection_service")


def _detect_causality():
    log.debug('Detecting causality')

    try:
        data = pd.read_csv("natural_data2.csv")
        data = data[np.where(data['Year'] == 1880)[0][0]:]
        output = granger_causality(data, ['Ozone', 'WMGHG'], 'Temperature', lags=3, our_type='trend')
        return output
    except Exception as e:
        raise e


class CausalityDetectionServicer(grpc_bt_grpc.CausalityDetectionServicer):
    """Causality detection servicer class to be added to the gRPC stub.
    Derived from protobuf (auto-generated) class."""

    def __init__(self):
        log.debug("CausalityDetectionServicer created!")
        
        self.result = Result()

        self.root_path = os.getcwd()
        self.input_dir = self.root_path + "/service/temp/input"
        service.initialize_diretories([self.input_dir])

    def treat_inputs(self, request, arguments):
        """Treats gRPC inputs and assembles lua command. Specifically, checks if required field have been specified,
        if the values and types are correct and, for each input/input_type adds the argument to the lua command."""

        model_path = self.model_dir
        # Base command is the prefix of the command (e.g.: 'th test.lua ')
        file_index_str = ""
        image_path = ""
        for field, values in arguments.items():
            # var_type = values[0]
            # required = values[1] Not being used now but required for future automation steps
            default = values[2]

            # Tries to retrieve argument from gRPC request
            try:
                arg_value = eval("request.{}".format(field))
            except Exception as e:  # AttributeError if trying to access a field that hasn't been specified.
                log.error(e)
                return False

            print("Received request.{} = ".format(field))
            print(arg_value)

            # Deals with each field (or field type) separately. This is very specific to the lua command required.
            if field == "input":
                log.debug("Treating input image field.")
                assert(request.input != ""), "Input image field should not be empty."
                try:
                    image_path, file_index_str = \
                        service.treat_image_input(arg_value, self.input_dir, "{}".format(field))
                    print("Image path: {}".format(image_path))
                    created_images.append(image_path)
                except Exception as e:
                    log.error(e)
                    raise
            elif field == "model":
                log.debug("Treating model field. Forcing model to be ESRGAN.")
                # if request.model == "ESRGAN":
                model_path += self.esrgan_model
                # else:
                #     log.error("Input field model not recognized. For now, only \"ESRGAN\" is accepted. Got: {}"
                #               .format(request.model))
            elif field == "scale":
                log.debug("Treating scale field. Forcing scale to be 4.")
                scale = 4
                model_path += str(scale)

                # If empty, fill with default, else check if valid
                # if request.scale == 0 or request.scale == "":
                #     scale = default
                # else:
                #     try:
                #         scale = int(request.scale)
                #     except Exception as e:
                #         log.error(e)
                #         raise
                # if scale in self.scale_dict[request.model]:
                #     model_path += str(scale)
                # else:
                #     log.error('Scale invalid. Should be one of {}.'.format(self.scale_dict[request.model]))
            else:
                log.error("Request field not found.")
                return False

        if image_path == "":
            log.error("Empty image_path (filename). Something went wrong when treating input.")
        model_path += self.model_suffix

        log.debug("Successfully treated input.")

        return image_path, model_path, file_index_str

    def detect_causality(self, request, context):
        """Evaluates causality using time series"""

        # Python command call arguments. Key = argument name, value = tuple(type, required?, default_value)
        arguments = {"csv_data": ("string", True, None),
                     "from_index": ("int", False, None),
                     "to_index": ("int", False, None),
                     "input_features": ("string", False, None),
                     "output_feature": ("string", True, None),
                     "lags": ("int", True, 3),
                     "modelling_type": ("int", True, "trend")}

        # Treat inputs
        try:
            image_path, model_path, file_index_str = self.treat_inputs(request, arguments)
        except HTTPError as e:
            error_message = "Error downloading the input image \n" + e.read()
            log.error(error_message)
            self.result.data = error_message
            return self.result
        except Exception as e:
            log.error(e)
            self.result.data = e
            return self.result

        log.debug("Treated input.")

        with Pool(1) as p:
            try:
                output = p.apply(_detect_causality, (model_path, image_path))
            except Exception as e:
                log.error(e)
                self.result.data = e
                return self.result
            # Get output file path
            log.debug("Returning on service complete!")
            input_filename = os.path.split(created_images[0])[1]
            log.debug("Input file name: {}".format(input_filename))
            output_image_path = self.output_dir + '/' + input_filename
            log.debug("Output image path: {}".format(output_image_path))

            try:
                # Write output image
                cv2.imwrite(output_image_path, output)
                created_images.append(output_image_path)
            except Exception as e:
                log.error("Error writing output image to file.")
                log.error(e)
                self.result.data = e
                return self.result

            # Prepare gRPC output message
            if input_filename.split('.')[1] == 'png':
                log.debug("Encoding from PNG.")
                self.result.data = service.png_to_base64(output_image_path).decode("utf-8")
            else:
                log.debug("Encoding from JPG.")
                self.result.data = service.jpg_to_base64(output_image_path, open_file=True).decode("utf-8")
            log.debug("Output image generated. Service successfully completed.")

            for image in created_images:
                service.serviceUtils.clear_file(image)

            return self.result


def serve(max_workers=5, port=7777):
    """The gRPC serve function.

    Params:
    max_workers: pool of threads to execute calls asynchronously
    port: gRPC server port

    Add all your classes to the server here.
    (from generated .py files by protobuf compiler)"""

    server = grpc.server(futures.ThreadPoolExecutor(max_workers=max_workers))
    grpc_bt_grpc.add_CausalityDetectionServicer_to_server(
        CausalityDetectionServicer(), server)
    server.add_insecure_port('[::]:{}'.format(port))
    log.debug("Returning server!")
    return server


if __name__ == '__main__':
    """Runs the gRPC server to communicate with the Snet Daemon."""
    parser = service.common_parser(__file__)
    args = parser.parse_args(sys.argv[1:])
    service.serviceUtils.main_loop(serve, args)
