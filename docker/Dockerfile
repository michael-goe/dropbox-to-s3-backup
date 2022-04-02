FROM ubuntu:20.04

RUN apt-get update && apt-get install -y curl unzip zip rclone 

WORKDIR /src
COPY rclone-run.sh /src
ENTRYPOINT [ "/src/rclone-run.sh" ]