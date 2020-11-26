FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
LABEL name="thelper"
LABEL description="Training framework and CLI for PyTorch-based machine learning projects"
LABEL vendor="Centre de Recherche Informatique de Montréal / Computer Research Institute of Montreal (CRIM)"
LABEL version="0.6.2"

ARG PYTHON_VERSION=3.7

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential git curl vim ca-certificates less && rm -rf /var/lib/apt/lists/*

ENV CONDA_HOME /opt/conda
ENV PATH ${CONDA_HOME}/bin:$PATH
RUN curl -o ~/miniconda.sh -LO  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p ${CONDA_HOME} && \
    rm ~/miniconda.sh && \
    ${CONDA_HOME}/bin/conda install -y python=$PYTHON_VERSION

ENV PROJ_LIB ${CONDA_HOME}/share/proj
ENV THELPER_HOME /opt/thelper
WORKDIR ${THELPER_HOME}

# NOTE:
#  force full reinstall with *possibly* updated even if just changing source
#  this way we make sure that it works with any recent dependency update
#COPY . .
RUN git clone -b infer-config https://github.com/plstcharles/thelper ${THELPER_HOME}

RUN sed -i 's/thelper/base/g' conda-env.yml
RUN conda env update --file conda-env.yml \
    && pip install opencv-python-headless \
    && conda clean --all -f -y
RUN pip install -q -e . --no-deps

# override base thelper
LABEL name="thelper-geo"
LABEL description.geo="Adds geospatial related packages to run machine learning projects with geo-referenced imagery"

# fix logged warning from GDAL sub-package when accessing Sentinel data via SAFE.ZIP
#   only problematic here when using the 'root' conda env
#   normal user installation with conda activation configures everything correctly
# (https://github.com/conda-forge/gdal-feedstock/issues/83#issue-162911573)
ENV CPL_ZIP_ENCODING=UTF-8

# everything already configured/copied by base thelper
# don't change directory to remain on specified workdir in base image
# only add extra geo packages
RUN sed -i 's/thelper/base/g' ${THELPER_HOME}/conda-env-geo.yml
RUN conda env update --file ${THELPER_HOME}/conda-env-geo.yml \
    && conda clean --all -f -y

WORKDIR /workspace
RUN chmod -R a+w /workspace

# Model installation
RUN git clone https://github.com/crim-ca/gin-model-repo ginmodelrepo-src
RUN pip install --quiet ./ginmodelrepo-src

# set default command
# NOTE:
#   avoid using 'entrypoint' as it requires explicit override which not all services do automatically
#   command is easier to override as it is the default docker run CLI input after option flags
#       ie:
#           command:        docker run [options] <your-cmd-override>
#       vs:
#           entrypoint:     docker run [options] --entrypoint="" <your-cmd-override>
#           # without "" override, Dockerfile entrypoint is executed and override command is completly ignored
CMD ["python", "-m", "thelper"]

