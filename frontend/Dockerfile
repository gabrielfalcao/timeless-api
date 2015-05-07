#
# Node.js w/ Bower & Grunt Dockerfile
#
# https://github.com/dockerfile/nodejs-bower-grunt
#

# Pull base image.
FROM node

# Define working directory.
WORKDIR /quietness

ADD . /quietness

# Install Bower & Grunt
RUN npm install -g bower grunt-cli
# Install stuff from package.json
RUN npm install
# Install bower dependencies
RUN bower install --allow-root

EXPOSE 9000

# Define default command.
CMD ["grunt"]