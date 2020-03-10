import logging
import os
import urllib.request
import time

logging.basicConfig(
    level=10, format="%(asctime)s - [%(levelname)8s] - %(name)s - %(message)s")
log = logging.getLogger(os.path.basename(__file__))


def main_loop(grpc_handler, args):
    """From gRPC docs:
    Because start() does not block you may need to sleep-loop if there is nothing
    else for your code to do while serving."""
    server = grpc_handler(port=args.grpc_port)
    server.start()
    try:
        while True:
            time.sleep(0.1)
    except KeyboardInterrupt:
        server.stop(0)


def download(url, filename):
    """Downloads a file given its url and saves to filename."""

    # Adds header to deal with images under https
    opener = urllib.request.build_opener()
    opener.addheaders = [('User-agent', 'Mozilla/5.0 (Windows NT x.y; Win64; x64; rv:9.0) Gecko/20100101 Firefox/10.0')]
    urllib.request.install_opener(opener)

    # Downloads the image
    try:
        urllib.request.urlretrieve(url, filename)
    except Exception:
        raise
    return


def clear_path(path):
    """ Deletes all files in a path. """

    for file in os.listdir(path):
        file_path = os.path.join(path, file)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
        except Exception as e:
            print(e)
    return


def clear_file(file_path):
    """ Deletes a file given its path."""

    try:
        if os.path.isfile(file_path):
            os.unlink(file_path)
    except Exception as e:
        print(e)
    return


def initialize_diretories(directories_list, clear_directories=True):
    """ Creates directories (or clears them if necesary)."""

    for directory in directories_list:
        if not os.path.exists(directory):
            os.makedirs(directory)
        else:
            if clear_directories:
                clear_path(directory)
