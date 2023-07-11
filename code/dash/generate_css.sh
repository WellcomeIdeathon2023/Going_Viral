#docker run -v $PWD/css:/static/public/css \
#  -v $PWD/variables.scss:/static/src/scss/partials/_user-variables.scss \
#  vimc/orderly-web-css-generator:master

docker run --rm -p 8888:8888 \
         -v $PWD:/orderly \
         -v $PWD/dash/config:/etc/orderly/web \
         -v $PWD/dash/logo:/static/public/img/logo \
         -v $PWD/dash/css:/static/public/css \
         -n qquavers_orderly_web \
         vimc/orderly-web-standalone:master
docker cp $PWD/dash/logo/favicon.ico qquavers_orderly_web:/static/public
