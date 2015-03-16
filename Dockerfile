FROM cnry/python:2.7

MAINTAINER gabriel@nacaolivre.org

ENV WORKERS 1

RUN adduser --quiet --system --uid 1000 --group --disabled-login \
  --home /srv/timeless timeless

WORKDIR /srv/timeless

RUN apt-get update \
  && apt-get --yes --no-install-recommends install \
  build-essential libevent-dev libffi-dev openjdk-7-jre openjdk-7-jdk nginx \
  && rm -rf /var/lib/apt/lists/*

# Adding these files here lets us add the entire source directory
# later, which means fewer cache invalidations for the install steps.
ADD requirements.txt /tmp/

# development.txt includes requirements.txt
RUN pip install -r /tmp/requirements.txt

# uwsgi
RUN pip install uwsgi

ADD . /srv/timeless

USER timeless

VOLUME /var/log

EXPOSE 5000

CMD exec uwsgi --enable-threads --http-socket 0.0.0.0.5000 --wsgi-file timeless/wsgi.py --master --processes $WORKERS