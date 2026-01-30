FROM ubuntu:latest
ENV DEBIAN_BACKEND=noninteractive

COPY scripts/install.sh /tmp/install.sh
RUN chmod +x /tmp/install.sh && bash /tmp/install.sh

WORKDIR /app

EXPOSE 8000 8000

CMD ["/bin/bash"]