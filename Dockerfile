FROM swift:latest

RUN apt-get clean \
  && apt-get -q update \
  && apt-get -q install -y sudo \
	&& rm -rf /var/lib/apt/lists/* \
  # && localedef -i en_US -f UTF-8 en_US.UTF-8 \
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
RUN cd ../
RUN sudo rm -rf SwiftLint


RUN swiftlint version


RUN brew install ruby

RUN gem install bundle
COPY Gemfile ./
COPY fastlane/Pluginfile ./fastlane
RUN bundle install
RUN brew install imagemagick
RUN brew install librsvg

ENV LINT_WORK_DIR "./sw"

VOLUME "${LINT_WORK_DIR}"
WORKDIR "${LINT_WORK_DIR}"
