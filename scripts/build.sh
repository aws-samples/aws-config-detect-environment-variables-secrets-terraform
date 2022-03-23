#!/bin/bash

layers=( "rdklib" "detect-secrets")

#Building layers
for i in "${layers[@]}"
do
  ./build_layer.sh ${i}
  zip -r ../src/layers/${i}-layer.zip ./python/
  rm -rf python
done