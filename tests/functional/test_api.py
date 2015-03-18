#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
import json
import uuid
import base64
from freezegun import freeze_time
from datetime import datetime
from timeless.models import User, Post, UserToken, NewsletterSubscription

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


@api
def test_log_in_fail_password(context):
    ('A user should get a 401 if failed to authenticate with bad password')
    # Given a User
    User.create(
        id=uuid.uuid1(),
        name=u'April Doe',
        email='jd@gmail.com',
        password=User.encrypt_password('Foo123'),
        date_added=datetime(1988, 2, 25),
    )

    # When I try to log in with the wrong password
    response = context.http.post(
        '/api/auth',
        data=json.dumps({
            'info': base64.b64encode(json.dumps({
                'email': 'jd@gmail.com',
                'password': 'dontknow',
            }))
        }),
        headers=context.headers,
    )

    # Then the response should be 401
    response.status_code.should.equal(401)

    # And if should contain a token
    data = json.loads(response.data)
    data.should.equal({u'message': u'could not authenticate', u'result': u'error'})


@api
def test_delete_post_that_belongs_to_her(context):
    ('A user can delete a post that belongs to her')
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
    # And that she has created a post
    post = user.create_post(
        title="foo bar",
        description="baz",
        body="The body",
        link="http://foo.bar",
    )

    # When I prepare the headers for authentication
    context.headers.update({
        'Authorization': 'Bearer: {0}'.format(user_token.token)
    })

    # And I DELETE to /api/posts
    response = context.http.delete(
        '/api/posts/{0}'.format(post.id),
        headers=context.headers,
    )

    # Then the response should be 200
    response.status_code.should.equal(200)

    # And there should be no posts
    results = list(Post.all())

    # Then it should be empty
    results.should.be.empty


@api
def test_subscribe_to_newsletter(context):
    ('Anyone should be able to put their email and create a subscription')

    # Given that I POST to /api/newsletter/subscribe
    response = context.http.post(
        '/api/newsletter/subscribe',
        data=json.dumps({
            'email': 'foo@bar.com',
        }),
        headers=context.headers,
    )

    # Then the response should be 200
    response.status_code.should.equal(200)

    # And there should be one newsletter subscription
    results = list(NewsletterSubscription.all())
    results.should.have.length_of(1)
