# Peter Stace's Blog

Repo contains Hugo site for my blog.

## Docker

```
docker build -t hugo .
docker run -v $PWD:/data hugo -c /data
```

## Publishing

```
./delpoy.sh
```

## Running Locally

```
hugo server --port 8080 --bind 0.0.0.0
```

## Creating a New Blog Post

```
hugo new post/YYYY-MM-DD-title-goes-here.md
```
