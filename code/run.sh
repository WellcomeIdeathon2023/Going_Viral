#!/usr/bin/env bash

set -ex

HERE=$(dirname $0)

docker run --rm -p 8888:8888 \
         -v $HERE:/orderly \
         -v $HERE/dash/config:/etc/orderly/web \
         -v $HERE/dash/logo:/static/public/img/logo \
         -v $HERE/dash/css:/static/public/css \
         --name qquavers_orderly_web -d \
         vimc/orderly-web-standalone:master

docker cp $HERE/dash/logo/favicon.ico qquavers_orderly_web:/static/public
