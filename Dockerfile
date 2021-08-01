# docker build --rm --tag myand .
# docker run --restart always -m 6096m -p 3333:22 -v ~/Documents/gradcache:/root/.gradle --rm -d --name man myand
# docker run -p 3333:22 -v ~/Documents/gradcache:/root/.gradle -v ~/keys/authorized_keys:/root/.ssh/authorized_keys -v ~/.android/debug.keystore:/root/.android/debug.keystore --rm -d --name man myand
# docker run --restart always -p 3333:22 -v ~/Documents/gradcache:/root/.gradle -v ~/keys/authorized_keys:/root/.ssh/authorized_keys -v ~/.android/debug.keystore:/root/.android/debug.keystore -d --name man bodos/android_mainframer
# copy your ssh pub key to this folder id_rsa_personal.pub

FROM openjdk:11
MAINTAINER Bohdan Trofymchuk "bohdan.trofymchuk@gmail.com"

# Install Deps
RUN apt-get --quiet update --yes
#RUN echo deb http://http.debian.net/debian jessie-backports main >> /etc/apt/sources.list
RUN apt-get --quiet install --yes apt-utils wget tar git unzip lib32stdc++6 lib32z1 rsync nano

RUN mkdir -p /opt/android-sdk-linux/cmdline-tools

# Install Android SDK
RUN cd /opt/android-sdk-linux/cmdline-tools && \
    wget --output-document=android-sdk.zip --quiet https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip && \
    unzip android-sdk.zip && \
    mv cmdline-tools tools && \
    rm -f android-sdk.zip && chown -R root.root /opt/android-sdk-linux


ENV VERSION_BUILD_TOOLS "30.0.2"
ENV VERSION_TARGET_SDK "30"
# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:/usr/local/openjdk-11/bin:$PATH

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license


RUN mkdir /root/.android
RUN touch /root/.android/repositories.cfg

# Install sdk elements
RUN (while [ 1 ]; do sleep 5; echo y; done) | ${ANDROID_HOME}/cmdline-tools/tools/bin/sdkmanager \
  "platform-tools" \
  "platforms;android-${VERSION_TARGET_SDK}" \
  # "platforms;android-28" \
  # "platforms;android-29" \
  "build-tools;${VERSION_BUILD_TOOLS}" \
  "extras;google;m2repository" "extras;google;google_play_services" "patcher;v4" --verbose

#install gradle
RUN cd /opt \
	&& wget --quiet --output-document=gradle.zip https://services.gradle.org/distributions/gradle-7.0.2-all.zip \
	&& unzip -q gradle.zip && rm -f gradle.zip && chown -R root.root /opt/gradle-7.0.2/bin
ENV PATH ${PATH}:/opt/gradle-7.0.2/bin
ENV HOME /root

# GO to workspace
RUN mkdir -p /opt/workspace
VOLUME /root/.gradle
WORKDIR /opt/workspace
COPY .bashrc /root/.bashrc

USER root
# Setup ssh server
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN ln /usr/local/openjdk-11/bin/java /usr/bin/java

EXPOSE 22
RUN mkdir /root/.ssh
COPY run.sh /root/run.sh

RUN java -version
RUN which java
RUN whereis java
RUN which android
RUN which git
RUN which gradle
RUN which adb

CMD ["sh","/root/run.sh"]
