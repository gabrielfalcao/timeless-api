# #!/usr/bin/env python
# # -*- coding: utf-8 -*-
# #
# from mock import patch
# from quietness.models import User


# @patch('quietness.models.Post')
# def test_create_post(Post):
#     ("User.create_post should create a post with the correct user id")

#     # Given a User
#     user = User(post_id=1)

#     # When I create a post
#     post = user.create_post(
#         id='whatever',
#         title='foobar',
#     )

#     # Then it should be a result of Post.create
#     post.should.equal(Post.create.return_value)

#     # And it should have used the user id
#     Post.create.assert_called_once_with(user_id='whatever')
