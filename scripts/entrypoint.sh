#!/bin/sh

set -x
# set -e

MORE_DEFAULT_OPTIONS="./config/MoreDefaultOptions"

COPY_SERVER_PROPERTIES=false

ETC_ARGS=""

for ARG in $@; do
    case $ARG in
        "--copy-server-properties")
            COPY_SERVER_PROPERTIES=true
            ;;
        *)
            ETC_ARGS="$ETC_ARGS $ARG"
        ;;
    esac
done

$COPY_SERVER_PROPERTIES && {
    cp ${MORE_DEFAULT_OPTIONS}/server.properties ./server.properties
}

set +x

BANNER_FILE="./banner.txt"
[ -f $BANNER_FILE ] || BANNER_FILE="./_docker_data/default-banner.txt"

printf "\n\n"

cat $BANNER_FILE

printf "\n\n+----------------------------------------------------------------\n"
echo "| JAVA HOME:         $JAVA_HOME"
echo "| JAVA VERSION:      $JAVA_VERSION"
echo "| ALPINE VERSION:    $JAVA_ALPINE_VERSION"
echo "| XMS:               $XMS"
echo "| XMX:               $XMX"
echo "| MODPACK VERSION:   $VERSION"
printf "+-----------------------------------------------------------------\n\n\n"

set -x
java -jar -Xms${XMS} -Xmx${XMX} $ETC_ARGS ./forge.jar