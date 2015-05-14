FROM gabrielfalcao/bower-grunt

WORKDIR /quietness

ADD . /quietness

RUN npm install grunt-contrib-imagemin
RUN npm install async
RUN npm install chalk
RUN npm install
RUN bower install --allow-root
RUN sed -i 's,9000,5050,g' Gruntfile.js

EXPOSE 5050

# Define default command.
CMD ["grunt"]