FROM scratch
ADD rootfs.tar.xz /

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



RUN apt -y install autoconf automake build-essential cmake doxygen git graphviz imagemagick libasound2-dev libass-dev libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libfreetype6-dev libgmp-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libopus-dev librtmp-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev libsnappy-dev libsoxr-dev libssh-dev libssl-dev libtool libv4l-dev libva-dev libvdpau-dev libvo-amrwbenc-dev libvorbis-dev libwebp-dev libx264-dev libx265-dev libxcb-shape0-dev libxcb-shm0-dev libxcb-xfixes0-dev libxcb1-dev libxml2-dev lzma-dev meson nasm pkg-config python3-dev python3-pip texinfo wget yasm zlib1g-dev libdrm-dev 

RUN mkdir -p /ffmpeg-libraries

RUN git clone --depth 1 https://github.com/mstorsjo/fdk-aac.git /ffmpeg-libraries/fdk-aac \
  && cd /ffmpeg-libraries/fdk-aac \
  && autoreconf -fiv \
  && ./configure \
  && make -j$(nproc) \
  && make install

RUN git clone --depth 1 https://code.videolan.org/videolan/dav1d.git /ffmpeg-libraries/dav1d \
  && mkdir /ffmpeg-libraries/dav1d/build \
  && cd /ffmpeg-libraries/dav1d/build \
  && meson .. \
  && ninja \
  && ninja install

RUN git clone --depth 1 https://github.com/ultravideo/kvazaar.git /ffmpeg-libraries/kvazaar \
  && cd /ffmpeg-libraries/kvazaar \
  && ./autogen.sh \
  && ./configure \
  && make -j$(nproc) \
  && make install

RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx /ffmpeg-libraries/libvpx \
  && cd /ffmpeg-libraries/libvpx \
  && ./configure --disable-examples --disable-tools --disable-unit_tests --disable-docs \
  && make -j$(nproc) \
  && make install

RUN git clone --depth 1 https://aomedia.googlesource.com/aom /ffmpeg-libraries/aom \
  && mkdir /ffmpeg-libraries/aom/aom_build \
  && cd /ffmpeg-libraries/aom/aom_build \
  && cmake -G "Unix Makefiles" AOM_SRC -DENABLE_NASM=on -DPYTHON_EXECUTABLE="$(which python3)" -DCMAKE_C_FLAGS="-mfpu=vfp -mfloat-abi=hard" .. \
  && sed -i 's/ENABLE_NEON:BOOL=ON/ENABLE_NEON:BOOL=OFF/' CMakeCache.txt \
  && make -j$(nproc) \
  && make install

RUN git clone https://github.com/sekrit-twc/zimg.git /ffmpeg-libraries/zimg \
  && cd /ffmpeg-libraries/zimg \
  && sh autogen.sh \
  && ./configure \
  && make \
  && make install

RUN ldconfig

RUN apt-get install -y libomxil-bellagio-dev sudo

WORKDIR "/root"
RUN git clone --depth 1 https://github.com/raspberrypi/userland.git
WORKDIR "/root/userland"
RUN ./buildme

RUN echo "/opt/vc/lib" > /etc/ld.so.conf.d/00-vmcs.conf
RUN ldconfig

RUN git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git /FFmpeg \
  && cd /FFmpeg \
  && PKG_CONFIG_PATH=/opt/vc/lib/pkgconfig ./configure \
    --extra-cflags="-I/usr/local/include" \
    --extra-ldflags="-L/usr/local/lib" \
    --extra-libs="-lpthread -lm" \
    --arch=armel \
    --enable-gmp \
    --enable-gpl \
    --enable-libaom \
    --enable-libass \
    --enable-libdav1d \
    --enable-libdrm \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libkvazaar \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsnappy \
    --enable-libsoxr \
    --enable-libssh \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libzimg \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxml2 \
    --enable-mmal \
    --enable-nonfree \
    --enable-omx \
    --enable-omx-rpi \
    --enable-version3 \
    --target-os=linux \
    --enable-pthreads \
    --enable-openssl \
    --enable-hardcoded-tables \
    --enable-shared \ 
  && make -j$(nproc) \
  && make install

RUN apt-get install -y libavdevice-dev libavfilter-dev libopus-dev libvpx-dev pkg-config libsrtp2-dev

RUN pip3 install aiohttp aiortc 

WORKDIR /
