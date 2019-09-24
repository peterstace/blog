FROM alpine
RUN wget 'https://github.com/gohugoio/hugo/releases/download/v0.58.3/hugo_0.58.3_Linux-64bit.tar.gz' \
	&& mkdir hugo \
	&& tar -xzvf *.tar.gz -C hugo 
ENTRYPOINT [ "/hugo/hugo" ]
