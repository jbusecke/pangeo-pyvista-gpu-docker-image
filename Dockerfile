# copied straight from https://github.com/pangeo-data/pangeo-docker-images/blob/master/ml-notebook/Dockerfile

# ONBUILD instructions in base-image/Dockerfile are used to
# perform certain actions based on the presence of specific
# files (such as conda-linux-64.lock, start) in this repo.
# Refer to the base-image/Dockerfile for documentation.
ARG PANGEO_BASE_IMAGE_TAG=master
FROM pangeo/base-image:${PANGEO_BASE_IMAGE_TAG}

RUN conda activate notebook
RUN mamba env update -f environment.yml

# # I wonder if I can just get the `vtk-egl-9.0.1*` wheel (https://github.com/pyvista/pyvista/releases/tag/0.27.0) from pip (see also here: https://docs.pyvista.org/version/stable/extras/building_vtk.html#building-wheels)
RUN pip install --no-cache-dir --extra-index-url https://wheels.vtk.org vtk-egl-9.0.1*

# #from https://github.com/pyvista/pyvista/issues/2142
# sudo apt install -y ninja-build cmake libgl1-mesa-dev python3-dev git
# sudo apt install -y python3.10-dev python3.10-distutils  # if using deadsnakes + Python 3.10
# # If on 18.04, you'll need a newer cmake. You can follow VTK's instructions @ https://apt.kitware.com

# # Linux/CentOS
# sudo yum install epel-release
# sudo yum install ninja-build cmake mesa-libGL-devel mesa-libGLU-devel

# git clone https://gitlab.kitware.com/vtk/vtk.git
# mkdir vtk/build
# cd vtk/build
# git checkout v9.1.0  # optional to select a version, but recommended

# export PYBIN=/usr/bin/python3.10  # select your version of choice
# cmake -GNinja \
#       -DCMAKE_BUILD_TYPE=Release \
#       -DVTK_BUILD_TESTING=OFF \
#       -DVTK_BUILD_DOCUMENTATION=OFF \
#       -DVTK_BUILD_EXAMPLES=OFF \
#       -DVTK_DATA_EXCLUDE_FROM_ALL:BOOL=ON \
#       -DVTK_MODULE_ENABLE_VTK_PythonInterpreter:STRING=NO \
#       -DVTK_MODULE_ENABLE_VTK_WebCore:STRING=YES \
#       -DVTK_MODULE_ENABLE_VTK_WebGLExporter:STRING=YES \
#       -DVTK_MODULE_ENABLE_VTK_WebPython:STRING=YES \
#       -DVTK_WHEEL_BUILD=ON \
#       -DVTK_PYTHON_VERSION=3 \
#       -DVTK_WRAP_PYTHON=ON \
#       -DVTK_OPENGL_HAS_EGL=False \
#       -DPython3_EXECUTABLE=$PYBIN ../
# ninja

# # build wheel in dist
# $PYBIN -m pip install wheel
# $PYBIN setup.py bdist_wheel
# $PYBIN -m pip install dist/vtk-*.whl  # optionally install it

# # if doing this, watch out if the nvidia drivers stays intact and match versions with GKE or the local machine. Do I have to run multiple images for each host? (https://docs.pyvista.org/version/stable/extras/docker.html#create-your-own-docker-container-with-pyvista)

# From https://github.com/pyvista/pyvista/blob/main/docker/jupyter.Dockerfile
# allow jupyterlab for ipyvtk
ENV JUPYTER_ENABLE_LAB=yes
ENV PYVISTA_TRAME_SERVER_PROXY_PREFIX='/proxy/'

# Required for nvidia drivers to work inside the image on GKE
# No-ops on other platforms - Azure doesn't need these set.
# Shouldn't negatively affect anyone, and makes life easier on GKE.
ENV PATH=${PATH}:/usr/local/nvidia/bin
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/nvidia/lib64
