#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
from __future__ import unicode_literals
import json
import base64
import logging
from tumbler import tumbler
from tumbler import json_response
from flask import abort
web = tumbler.module(__name__)

# from timeless.models import Post
from timeless.api.core import authenticated, ensure_json_request
from timeless.models import User


@web.post('/api/posts')
@authenticated
def create_post(user):
    data = ensure_json_request({
        'title': unicode,
        'slug': any,
        'body': any,
        'description': any,
        'link': any,
    })

    post = user.create_post(**data)
    logging.info('creating post %s by %s', post.title, user.email)

    return json_response({
        'result': 'OK',
        'message': 'Post created',
        'uuid': post.id,
        'url': post.get_url()
    })


def parse_auth_payload():
    data = ensure_json_request({
        'info': unicode,
    })
    info = data['info']
    raw = base64.b64decode(info)
    return json.loads(raw)


@web.post('/api/auth')
def authenticate_user():
    data = parse_auth_payload()

    email = data.pop('email')
    given_password = data.pop('password')

    token = User.authenticate(email, given_password)
    if token:
        return json_response({
            'token': token.token,
            'created_at': token.date_created.isoformat()
        })

    abort(404)
