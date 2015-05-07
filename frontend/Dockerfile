#
# Node.js w/ Bower & Grunt Dockerfile
#
# https://github.com/dockerfile/nodejs-bower-grunt
#

# Pull base image.
FROM node

# Install Bower & Grunt
RUN npm install -g bower grunt-cli

# Define working directory.
WORKDIR /quietness

COPY . /quietness

RUN npm install -g
RUN bower install --allow-root

EXPOSE 9000

# Define default command.
CMD ["grunt"]