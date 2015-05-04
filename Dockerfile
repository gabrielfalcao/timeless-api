FROM cnry/python:2.7

MAINTAINER gabriel@nacaolivre.org

ENV WORKERS 1
ENV QUIETNESS_CASSANDRA_HOST: localhost
ENV QUIETNESS_CASSANDRA_PORT: 5000

RUN adduser --quiet --system --uid 1000 --group --disabled-login \
  --home /srv/quietness quietness

WORKDIR /srv/quietness

RUN apt-get update \
  && apt-get --yes --no-install-recommends install \
  build-essential libevent-dev libffi-dev openjdk-7-jre openjdk-7-jdk nginx \
  && rm -rf /var/lib/apt/lists/*

ADD requirements.txt /tmp/

# development.txt includes requirements.txt
RUN pip install -r /tmp/requirements.txt

# uwsgi
RUN pip install uwsgi

ADD . /srv/quietness

USER quietness

EXPOSE 5000

CMD exec uwsgi --enable-threads --http-socket 0.0.0.0.5000 --wsgi-file quietness/wsgi.py --master --processes $WORKERS
