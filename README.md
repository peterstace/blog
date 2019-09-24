# Peter Stace's Blog

Repo contains Hugo site for my blog.

## Docker

```fish
docker build -t hugo .
docker run -u (id -u $USER) -v $PWD:/data hugo
```
