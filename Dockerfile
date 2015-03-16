FROM cnry/python:2.7

MAINTAINER gabriel@nacaolivre.org

ENV WORKERS 1

RUN adduser --quiet --system --uid 1000 --group --disabled-login \
  --home /srv/timeless timeless

WORKDIR /srv/timeless

RUN apt-get update \
  && apt-get --yes --no-install-recommends install \
  build-essential libevent-dev libffi-dev openjdk-7-jre openjdk-7-jdk \
  && rm -rf /var/lib/apt/lists/*

# Adding these files here lets us add the entire source directory
# later, which means fewer cache invalidations for the install steps.
ADD requirements.txt /tmp/

# development.txt includes requirements.txt
RUN pip install -r /tmp/requirements.txt

ADD . /srv/timeless

USER timeless

ENV TIMELESS_PORT 8080

EXPOSE 8080

CMD exec uwsgi $UWSGI_OPTS --http :$TIMELESS_PORT --workers $WORKERS \
  --wsgi-file timeless/wsgi.py
