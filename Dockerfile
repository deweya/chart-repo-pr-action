FROM alpine

## According to the GH Actions doc, the user must run as root
## https://docs.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions#user
USER root

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]