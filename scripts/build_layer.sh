#!/bin/bash
export PKG_DIR="python/lib/python3.8/site-packages"
rm -rf ${PKG_DIR} && mkdir -p ${PKG_DIR}

docker run --rm -v $(pwd):/package -w /package lambci/lambda:build-python3.8 \
pip3 install $1 -t ${PKG_DIR}