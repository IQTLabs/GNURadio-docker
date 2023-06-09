ARG DEPENDENCIES_VERSION="latest"
FROM iqtlabs/gnuradio-dependencies:${DEPENDENCIES_VERSION} as builder

ARG GNURADIO_TAG

WORKDIR /root
# includes rx_freq tag - https://github.com/gnuradio/gnuradio/commit/915601c4a5d994532815fbd5c75a3c34f1fbd320
RUN git clone https://github.com/gnuradio/gnuradio -b ${GNURADIO_TAG}
WORKDIR /root/gnuradio/build
RUN CMAKE_CXX_STANDARD=17 cmake -DENABLE_DEFAULT=ON -DENABLE_PYTHON=ON -DENABLE_GNURADIO_RUNTIME=ON -DENABLE_GR_BLOCKS=ON -DENABLE_GR_FFT=ON -DENABLE_GR_FILTER=ON -DENABLE_GR_ANALOG=ON -DENABLE_GR_UHD=ON -DENABLE_GR_NETWORK=ON -DENABLE_GR_SOAPY=ON -DENABLE_GR_ZEROMQ=ON .. && make -j "$(nproc)" && make install

FROM iqtlabs/gnuradio-dependencies:${DEPENDENCIES_VERSION}
COPY --from=builder /usr/local /usr/local
RUN ln -s /usr/local/lib/python3/dist-packages/* /usr/local/lib/python3.10/dist-packages
RUN ldconfig -v
RUN python3 -c "from gnuradio import analog, blocks, gr, network, soapy, zeromq"
