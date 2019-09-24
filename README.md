# Peter Stace's Blog

Repo contains Hugo site for my blog.

## Docker

```
docker build -t hugo .
docker run -v $PWD:/data hugo server -c /data
```
