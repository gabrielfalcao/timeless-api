#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# flake8: noqa
import os
import logging

from tumbler.core import Web

from pythonjsonlogger import jsonlogger
from plant import Node
from quietness import routes

import logging
import sys

root = logging.getLogger()

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)

formatter = jsonlogger.JsonFormatter(
    '%(levelname)s %(asctime)s %(module)s %(process)d %(message)s %(pathname)s $(lineno)d $(funcName)s')

handler.setFormatter(formatter)
root.addHandler(handler)

root_node = Node(__file__).dir

application = Web()


if __name__ == '__main__':
    from wsgiref.simple_server import make_server
    make_server('', 8000, application).serve_forever()
