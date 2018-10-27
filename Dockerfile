FROM swift:latest


RUN apt-get clean \
  && apt-get -q update \
  && apt-get -q install -y sudo \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y locales

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

RUN rm -rf /var/lib/apt/lists/* \
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
RUN git clone https://github.com/realm/SwiftLint.git
WORKDIR "SwiftLint"

# RUN git reset --hard "${SWIFTLINT_REVISION}"
RUN git submodule update --init --recursive; sudo make install
WORKDIR /home/linuxbrew
RUN sudo rm -rf SwiftLint 

RUN swiftlint version


RUN brew install ruby
RUN brew install librsvg

RUN gem install bundle
COPY Gemfile Gemfile.lock ./config/
COPY fastlane/Pluginfile ./config/fastlane/
WORKDIR /home/linuxbrew/config
RUN bundle install

WORKDIR /home/linuxbrew

# RUN brew install imagemagick
RUN curl https://imagemagick.org/download/ImageMagick.tar.gz -o ImageMagick.tar.gz && \
    tar -xzvf ImageMagick.tar.gz && ls &&\
    cd ImageMagick-7.0.8-14/ && \
    ./configure
WORKDIR /home/linuxbrew
RUN sudo rm -rf ImageMagick-7.0.8-14 ImageMagick.tar.gz ruby-2.4.0.tar.gz
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN swift --version