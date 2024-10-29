FROM alpine:3.19

RUN apk add --no-cache bash curl iputils

WORKDIR /app

COPY scripts/monitor.sh .
RUN chmod +x monitor.sh

CMD ["./monitor.sh"]
