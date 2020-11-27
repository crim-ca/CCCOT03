ARG BASE_IMAGE=pytorch/torchserve:latest-gpu

FROM ${BASE_IMAGE} AS compile-image
ARG BASE_IMAGE=pytorch/torchserve:latest-gpu

USER root

RUN apt-get update -y && apt-get install -y python3-distutils git
RUN apt-get install -y software-properties-common
# RUN apt-add-repository ppa:ubuntugis/ubuntugis-unstable && apt-get update && apt-get install -y python-gdal

RUN apt-get install -y python3-dev 
RUN add-apt-repository ppa:ubuntugis/ppa && apt-get update
RUN apt-get update
RUN apt-get install -y gdal-bin
RUN apt-get install -y libgdal-dev
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal
RUN apt-get install -y python-gdal

RUN pip install --upgrade pip
RUN pip install GDAL==$(gdal-config --version) --global-option=build_ext --global-option="-I/usr/include/gdal"


RUN pip install pillow gitpython lz4 matplotlib numpy pyyaml scikit-learn six tqdm h5py opencv-python  pretrainedmodels albumentations pyyaml
RUN pip --quiet install affine geojson shapely pyproj hdf5plugin kornia==0.3.2

RUN mkdir -p /home/model
WORKDIR /home/model

RUN git clone  https://github.com/plstcharles/thelper.git thelper-src
RUN pip install --quiet ./thelper-src

RUN git clone  https://github.com/crim-ca/gin-model-repo gin-src
RUN pip install --quiet ./gin-src


WORKDIR /home/model-server
