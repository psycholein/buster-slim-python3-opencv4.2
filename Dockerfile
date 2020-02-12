FROM raspbian:buster

RUN apt-get update -y && apt-get install -y \
	build-essential cmake pkg-config \
	libjpeg-dev libtiff5-dev libpng-dev \
	libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
	libxvidcore-dev libx264-dev \
	libfontconfig1-dev libcairo2-dev \
	libgdk-pixbuf2.0-dev libpango1.0-dev \
	libgtk2.0-dev libgtk-3-dev \
	libatlas-base-dev gfortran \
	libhdf5-dev libhdf5-serial-dev libhdf5-103 \
	libtbb2 libtbb-dev qt5-default \
	libmp3lame-dev libtheora-dev \
	libvorbis-dev libxvidcore-dev libx264-dev \
	libopencore-amrnb-dev libopencore-amrwb-dev \
	libavresample-dev \
	x264 v4l-utils \
	libqtgui4 libqtwebkit4 libqt4-test python3-pyqt5 \
	python3 python3-distutils python3-dev python3-pip \
	curl wget unzip

RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.2.0.zip
RUN wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.2.0.zip
RUN unzip opencv.zip
RUN unzip opencv_contrib.zip

RUN mv opencv-4.2.0 opencv
RUN mv opencv_contrib-4.2.0 opencv_contrib

RUN pip3 install numpy

RUN mkdir -p /app

RUN mkdir -p /opencv/build
WORKDIR /opencv/build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
    -D ENABLE_NEON=ON \
    -D ENABLE_VFPV3=ON \
    -D BUILD_TESTS=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF ..
RUN make -j4
RUN make install
RUN ldconfig

WORKDIR /app
