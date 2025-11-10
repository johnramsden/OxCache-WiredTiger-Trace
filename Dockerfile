# Dockerfile for WiredTiger
# Multi-stage build to create a clean runtime image

FROM ubuntu:22.04 AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CMAKE_BUILD_TYPE=Release

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    pkg-config \
    python3 \
    python3-dev \
    libpython3-dev \
    swig \
    liblz4-dev \
    libsnappy-dev \
    zlib1g-dev \
    libzstd-dev \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create build directory
WORKDIR /build

# Copy WiredTiger source code
COPY . /build/wiredtiger

# Build WiredTiger
WORKDIR /build/wiredtiger
RUN mkdir -p build && \
    cd build && \
    cmake .. \
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DENABLE_STATIC=ON \
        -DENABLE_SHARED=ON \
        -DENABLE_PYTHON=ON \
        -DENABLE_LZ4=ON \
        -DENABLE_SNAPPY=ON \
        -DENABLE_ZLIB=ON \
        -DENABLE_ZSTD=ON \
        -DHAVE_DIAGNOSTICS=ON \
        -DHAVE_ERROR_LOG=ON && \
    make -j$(nproc) && \
    make install && \
    # Build wtperf benchmark tool
    cd bench/wtperf && \
    make -j$(nproc) && \
    cp wtperf /usr/local/bin/

# Runtime stage
FROM ubuntu:22.04 AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    liblz4-1 \
    libsnappy1v5 \
    zlib1g \
    libzstd1 \
    libssl3 \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Copy built libraries and binaries from builder stage
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/include /usr/local/include

RUN ldconfig

COPY bench/wtperf/runners/ycsb-trace* /perf/
COPY bench.sh /data/

WORKDIR /data

# RUN ./bench.sh

# Expose default WiredTiger port (if applicable)
# EXPOSE 28015

# Default command
CMD ["./bench.sh"]
