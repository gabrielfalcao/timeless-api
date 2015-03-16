#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
import json
import uuid
import base64
from freezegun import freeze_time
from datetime import datetime
from timeless.models import User, Post, UserToken

from .helpers import api


@api
def test_create_post(context):
    ('A user can create a post')
    # Given a User containing that token
    user = User.create(
        id=uuid.uuid1(),
        name=u'April Doe',
        email='jd@gmail.com',
        password='123',
        date_added=datetime(1988, 2, 25),
    )
    # And a Token
    user_token = UserToken.create(
        token=str(uuid.uuid4()),
        user_id=user.id
    )

    # When I prepare the headers for authentication
    context.headers.update({
        'Authorization': 'Bearer: {0}'.format(user_token.token)
    })

    # And I POST to /api/posts
    response = context.http.post(
        '/api/posts',
        data=json.dumps({
            'title': 'foo bar',
            'description': 'baz',
            'body': 'The body',
            'link': 'http://foo.bar',
        }),
        headers=context.headers,
    )

    # Then the response should be 200
    response.status_code.should.equal(200)
    # And it should be in the list of posts
    results = list(Post.all())

    # Then it should have one result
    results.should.have.length_of(1)

    # And that one result should match the created Post
    post = results[0]
    post.user_id.should.equal(user.id)
    post.title.should.equal('foo bar')
    post.description.should.equal('baz')
    post.body.should.equal('The body')
    post.link.should.equal('http://foo.bar')


@freeze_time('2015-03-14')
@api
def test_log_in(context):
    ('A user should be able to authenticate')
    # Given a User
    User.create(
        id=uuid.uuid1(),
        name=u'April Doe',
        email='jd@gmail.com',
        password=User.encrypt_password('Foo123'),
        date_added=datetime(1988, 2, 25),
    )

    # When I try to log in
    response = context.http.post(
        '/api/auth',
        data=json.dumps({
            'info': base64.b64encode(json.dumps({
                'email': 'jd@gmail.com',
                'password': 'Foo123',
            }))
        }),
        headers=context.headers,
    )

    # Then the response should be 200
    response.status_code.should.equal(200)

    # And if should contain a token
    data = json.loads(response.data)
    data.should.have.key('token').should.match(r'\w+-\w+-\w+-\w+-\w+')
    data.should.have.key('token').should.have.length_of(36)
    data.should.have.key('created_at').being.equal('2015-03-14T00:00:00')
