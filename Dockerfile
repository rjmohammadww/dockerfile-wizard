FROM ubuntu:18.04

RUN  apt-get -q update && \
     apt-get -q install -y  --no-install-recommends ca-certificates file g++ git locales make uuid-runtime \
    libc6-dev \
    clang \
    curl \
    libedit-dev \
    libpython2.7 \
    libicu-dev \
    libssl-dev \
    libxml2 \
    git \
    libcurl4-openssl-dev \
    pkg-config 

ARG SWIFT_PLATFORM=ubuntu16.04
ARG SWIFT_BRANCH=swift-4.1.3-release
ARG SWIFT_VERSION=swift-4.1.3-RELEASE

ENV SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_BRANCH=$SWIFT_BRANCH \
    SWIFT_VERSION=$SWIFT_VERSION

RUN SWIFT_URL=https://swift.org/builds/swift-4.2-release/ubuntu1804/swift-4.2-RELEASE/swift-4.2-RELEASE-ubuntu18.04.tar.gz \
    && curl -fSsL $SWIFT_URL -o swift.tar.gz \
    && curl -fSsL $SWIFT_URL.sig -o swift.tar.gz.sig \
    # && export GNUPGHOME="$(mktemp -d)" \
    # && set -e; \
    #     for key in \
    #   # pub   rsa4096 2017-11-07 [SC] [expires: 2019-11-07]
    #   # 8513444E2DA36B7C1659AF4D7638F1FB2B2B08C4
    #   # uid           [ unknown] Swift Automatic Signing Key #2 <swift-infrastructure@swift.org>
    #       8513444E2DA36B7C1659AF4D7638F1FB2B2B08C4 \
    #   # pub   4096R/91D306C6 2016-05-31 [expires: 2018-05-31]
    #   #       Key fingerprint = A3BA FD35 56A5 9079 C068  94BD 63BC 1CFE 91D3 06C6
    #   # uid                  Swift 3.x Release Signing Key <swift-infrastructure@swift.org>
    #       A3BAFD3556A59079C06894BD63BC1CFE91D306C6 \
    #   # pub   4096R/71E1B235 2016-05-31 [expires: 2019-06-14]
    #   #       Key fingerprint = 5E4D F843 FB06 5D7F 7E24  FBA2 EF54 30F0 71E1 B235
    #   # uid                  Swift 4.x Release Signing Key <swift-infrastructure@swift.org>          
    #       5E4DF843FB065D7F7E24FBA2EF5430F071E1B235 \
    #     ; do \
    #       gpg --quiet --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    #     done \
    # && gpg --batch --verify --quiet swift.tar.gz.sig swift.tar.gz \
    && tar -xzf swift.tar.gz --directory  / --strip-components=1 \
    # && rm -r "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz \
    && chmod -R o+r  /usr/lib/swift 

RUN swift --version

RUN git clone https://github.com/realm/SwiftLint.git

WORKDIR "SwiftLint"
RUN git submodule update --init --recursive
RUN apt-get install wget -y &&  wget http://security.ubuntu.com/ubuntu/pool/main/i/icu/libicu55_55.1-7_amd64.deb
RUN dpkg -i libicu55_55.1-7_amd64.deb
# RUN apt install curl -y
RUN make install

RUN swiftlint version

RUN apt-get clean \
  && apt-get -q install -y sudo \
	&& rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -f UTF-8 en_US.UTF-8 \
	&& useradd -m -s /bin/bash linuxbrew \
	&& echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

USER linuxbrew
WORKDIR /home/linuxbrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/usr/bin:$PATH \
	SHELL=/bin/bash

RUN git clone https://github.com/Linuxbrew/brew.git /home/linuxbrew/.linuxbrew/Homebrew \
	&& mkdir /home/linuxbrew/.linuxbrew/bin \
	&& ln -s ../Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/ \
	&& brew config

# RUN sudo apt-get update && sudo apt install libcurl4-openssl-dev -y

RUN wget http://ftp.ruby-lang.org/pub/ruby/2.4/ruby-2.4.0.tar.gz && \
    tar -xzvf ruby-2.4.0.tar.gz && \
    cd ruby-2.4.0/ && \
    ./configure && \
    sudo make -j4 && \
    sudo make install && \
    ruby -v

RUN brew install imagemagick
RUN brew install librsvg
RUN sudo gem install bundle
COPY Gemfile ./
COPY fastlane/Pluginfile ./fastlane
RUN bundle install


RUN swiftlint version

RUN swift --version

# RUN sudo apt-get install -y apt-utils git-core
# RUN apt-get install -y 
# RUN sudo apt-get -f install
# RUN sudo apt-get update
# RUN sudo apt-get install -y wget clang libblocksruntime0 libcurl4-openssl-dev libicu-dev
# # RUN sudo apt-get upgrade -y libstdc++6
# # # RUN sudo apt-get upgrade -y
# RUN strings /usr/lib/x86_64-linux-gnu/libstdc++.so.6 | grep GLIBCXX
# RUN sudo curl https://swift.org/builds/swift-4.2-release/ubuntu1804/swift-4.2-RELEASE/swift-4.2-RELEASE-ubuntu18.04.tar.gz | tar xz --directory /home/linuxbrew --strip-components=1
# # RUN cd ./usr/lib && ls
# # RUN sudo apt-get upgrade -y libstdc++6
# # RUN sudo apt-get install libtinfo5
# RUN sudo apt-get install -y libpython2.7 libbsd0
# RUN git clone https://github.com/realm/SwiftLint.git
# ENV LINUX_SOURCEKIT_LIB_PATH=/home/linuxbrew/usr/lib
# WORKDIR "SwiftLint"
# # RUN git reset --hard 0.25.1
# RUN swift 
# RUN sudo git submodule update --init --recursive; sudo make install
# RUN swiftlint version
# # RUN swift run -c release swiftlint
# # RUN mv .build/x86_64-unknown-linux/release/swiftlint /usr/local/bin/

# # RUN cd ..

# RUN rm -rf SwiftLint

