FROM debian:12

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    g++ \
    cmake \
    make \
    git \
    wget \
    unzip \
    libgtk-3-dev \
    libgl-dev \
    libglu1-mesa-dev \
    libpng-dev \
    libjpeg-dev \
    libboost1.81-dev \
    libboost-regex1.81-dev \
    libboost-json1.81-dev \
    libhunspell-dev \
    libicu72 \
    && rm -rf /var/lib/apt/lists/*

# Build and install wxWidgets 3.3.1 from source (not in any distro repo yet)
RUN git clone --depth=1 --branch v3.3.1 --recurse-submodules --shallow-submodules \
        https://github.com/wxWidgets/wxWidgets.git /tmp/wxWidgets \
    && cmake -S /tmp/wxWidgets -B /tmp/wxWidgets/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DwxBUILD_TESTS=OFF \
        -DwxUSE_STC=OFF \
        -DwxUSE_ICU=OFF \
    && cmake --build /tmp/wxWidgets/build -- -j$(nproc) \
    && cmake --install /tmp/wxWidgets/build \
    && ldconfig \
    && rm -rf /tmp/wxWidgets
