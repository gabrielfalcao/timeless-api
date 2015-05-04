# Quietness API

Backend for quietness

## Installing

you will need to install cassandra :+1:

```bash
brew install cassandra
```

Follow the homebrew instructions and make sure that cassandra is running in your computer

## Running

```bash
make run
```

## Testing

```bash
make unit
make functional
```


## Endpoints


### user login

```bash
POST http://quietness.co/api/auth
{
    "info": "Base64-encoded json string containing `email` and `password`"
}
```

#### example

```python
import requests, json, base64

response = context.http.post(
    '/api/auth',
    data=json.dumps({
        'info': base64.b64encode(json.dumps({
            'email': 'jd@gmail.com',
            'password': 'dontknow',
        }))
    }),
    headers={"Content-Type": "application/json"},
)
````

#### response

```python
{
    "token": "YOURTOKEN"
}
```

### creating a post

```bash
POST http://quietness.co/api/posts
{
    "title": "foo bar",
    "description": "baz",
    "body": "The body",
    "link": "http://foo.bar"
}
```

#### example

```python
import requests, json, base64

response = context.http.post(
    '/api/auth',
    data=json.dumps({
        "title": "foo bar",
        "description": "baz",
        "body": "The body",
        "link": "http://foo.bar"
    }),
    headers={
        "Content-Type": "application/json",
        "Authorization": "Bearer: YOURTOKEN"
    },
)
````
