# Peter Stace's Blog

Repo contains Hugo site for my blog.

## Docker

Server mode:

```fish
docker run -u (id -u $USER):(id -g $USER) -v $PWD/blog:/data -p 8081:1313 hugo server --bind 0.0.0.0
```

Add new post:

```fish
docker run -u (id -u $USER):(id -g $USER) -v $PWD/blog:/data hugo new posts/my-new-post.md
```

## TODO

- List template.
- Dynamic copyright year.
- Factor out header/footer.
- Reduce to fixed with.
- Misc styling.
