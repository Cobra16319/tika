# latest 18MAR Cobra (Working DockerFile)
# Define global args

ARG FUNCTION_DIR="/home/app/"
ARG RUNTIME_VERSION="3.8"
ARG DISTRO_VERSION="3.12"

# Stage 1 - bundle base image + runtime
# Grab a fresh copy of the image and install GCC

FROM python:${RUNTIME_VERSION}-alpine${DISTRO_VERSION} AS python-alpine

# Install GCC (Alpine uses musl but we compile and link dependencies with GCC)

RUN apk add --no-cache \
    libstdc++
# Stage 2 - build function and dependencies
FROM python-alpine AS build-image
# Install aws-lambda-cpp build dependencies
RUN apk add --no-cache \
    build-base \
    libtool \
    autoconf \
    automake \
    libexecinfo-dev \
    make \
    cmake \
    libcurl

### 2.5 Get Java via the package manager
RUN apk update \
&& apk upgrade \
&& apk add --no-cache bash \
&& apk add --no-cache --virtual=build-dependencies unzip \
&& apk add --no-cache curl \
&& apk add --no-cache openjdk8-jre \
&& apk add python3 python3-dev gcc g++ gfortran musl-dev libxml2-dev libxslt-dev
ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"
# Include global args in this stage of the build

ARG FUNCTION_DIR
ARG RUNTIME_VERSION

# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Copy handler function
COPY /* ${FUNCTION_DIR}

# Add requirements.txt file

ADD requirements.txt ${FUNCTION_DIR}

# Install Lambda Runtime Interface Client for Python

RUN python${RUNTIME_VERSION} -m pip install awslambdaric --target ${FUNCTION_DIR}

# Add python file

ADD textract.py ${FUNCTION_DIR}

# Stage 3 - final runtime image
# Grab a fresh copy of the Python image

FROM python-alpine

# Include global arg in this stage of the build

ARG FUNCTION_DIR

# Set working directory to function root directory

WORKDIR ${FUNCTION_DIR}

# Copy in the built dependencies

COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

# (Optional) Add Lambda Runtime Interface Emulator and use a script in the ENTRYPOINT for simpler local runs

ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie

# Test it at the later stage since this is working directory

RUN python${RUNTIME_VERSION} -m pip install -r requirements.txt --target ${FUNCTION_DIR}

COPY entry.sh /

RUN chmod 755 /usr/bin/aws-lambda-rie /entry.sh

ENTRYPOINT [ "/entry.sh" ]

### Test

CMD [ "textract.lambda_handler" ]

















© 2008 - 2021, Amazon Web Services, Inc. or its affiliates. All rights reserved.
