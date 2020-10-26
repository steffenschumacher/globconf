# This file describes a docker image for hosting auth protected cfg files in docker
#
# Build the docker image:
#     docker build -t globconfd -f Dockerfile .
#
# Run with mapping of relevant user config file and directory hosting config/env files.
# -i -t is for interactive, use -d if you wish to run the container in the background:
#     docker run -i -t globconfd --name globconfd -v ./users.conf:env_users.conf \
#         -v ./cfgs:/configs globconfd
#
# Most configuration variables are provided via environment variables.
#   ENVUSERROOT         Override default path of config files
#   ENVUSERCFGFILE      Override path to config file containing valid users
#
# The mapped ENVUSERCFGFILE file must contain a separate configparser section for each user:
#
# [app_user]
# path_regex = production/someapp\.ini    << regex to control which url(s) is accesible
# username = app_user
# password = app_pass
#
#
# The ENVUSERROOT path must be mapped to a local folder having all the hosted cfg files.
# If a file is placed in ENVUSERROOT/production/file.ini then the url will be /production/file.ini
#
FROM ubuntu:18.04

MAINTAINER Steffen Schumacher "ssch@wheel.dk"

ENV ENVUSERROOT=/configs ENVUSERCFGFILE=/env_users.conf PYTHONIOENCODING=utf-8

RUN apt-get update -y
RUN apt-get install -y python3-pip python3-dev
RUN pip3 install --trusted-host pypi.org --upgrade pip Flask Flask-HTTPAuth

COPY globconf/cfgfilestore.py /
COPY env_users.conf.dist /env_users.conf
RUN chmod 755 cfgfilestore.py

ENTRYPOINT [ "./cfgfilestore.py" ]

