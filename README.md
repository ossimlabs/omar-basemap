# omar-basemap

## Description

The OMAR Basemap service provides Open Street Map tiles to the web application and the user.

This repo currently has a Dockerfile and a Docker image.  Currently the Dockerfile and image are both based on Debian.  The Dockerfile was pulled from this repo: https://github.com/klokantech/tileserver-gl

Build the docker image by doing the following: docker build .
If you want to give the image a name, you can do: docker build -t <name> .
(The build docker image is also in this repo)

To run, use the following command: docker run -it -v /data -p 8080:80 klokantech/tileserver-gl

Instructions for running the Tileserver through means other than Docker are here: https://hub.docker.com/r/klokantech/tileserver-gl/
