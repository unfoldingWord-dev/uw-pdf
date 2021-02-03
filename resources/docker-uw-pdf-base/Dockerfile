#FROM tiangolo/uwsgi-nginx-flask:python3.7 # uW PDFOLETE because we switched to RQ
# See https://hub.docker.com/_/python/ for available packages
# FROM python:3.7-slim-stretch
# Brings in ConTeXt MkIV 2016.05
#   but Python 3.7 is not natively compatible with pickle protocol v8
#       see https://github.com/rq/rq/issues/1168
#FROM python:3.8-slim-buster
# Brings in ConTeXt MkIV 2018.04.04 which seems to have different syntax
FROM unfoldingword/uw-pdf-stretch-base:latest
# Brings in ConTeXt MkIV 2016.05
#   but has Python 3.8.1

# install packages, nodejs, and the uW PDF images
RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y apt-utils \
    && apt-get install -y \
        git unzip \
        bzip2 \
        libfontconfig1 \
        curl \
        haskell-platform \
        pandoc \
        pandoc-citeproc \
        texlive \
        python3-pandocfilters \
        libghc-pandoc-doc \
        libghc-pandoc-dev \
        fonts-noto \
        context \
        wget \
        nano \
    && curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh \
    && chmod +x nodesource_setup.sh \
    && ./nodesource_setup.sh \
    && apt-get install -y nodejs \
    && mkdir -p /opt/uw-pdf/png \
    && mkdir -p /opt/uw-pdf/jpg \
    && curl -sL https://cdn.door43.org/uw-pdf/png/uW_OBS_Logo.png -o /opt/uw-pdf/png/uW_uW PDF_Logo.png \
    && unzip /opt/uw-pdf/jpg/uw-pdf-images-360px.zip -d /opt/uw-pdf/jpg \
    && rm -v /opt/uw-pdf/jpg/uw-pdf-images-360px.zip
