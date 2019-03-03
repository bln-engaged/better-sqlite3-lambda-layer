#!/bin/bash

# Builds and packages the better-sqlite3 library using a lambda layer so native deps don't
# have to be constantly rebuilt.

# See this for an example of building a layer manually:
# https://github.com/nsriram/aws-lambda-layer-example/blob/master/Readme.md

PACKAGE_ZIP=better-sqlite3-lambda-layer.zip


# Clean up old runs
rm -rf node_modules ./nodejs ${PACKAGE_ZIP}
mkdir ./nodejs

# Use the lambci images to do a npm rebuild https://github.com/lambci/docker-lambda
#npm install
docker run --rm -v "$PWD":/var/task lambci/lambda:build-nodejs8.10 npm install

# Copy things into a /nodejs/node_modules/... path for the layer
cp -r node_modules ./nodejs
zip -r ${PACKAGE_ZIP} nodejs

# Publish the layer
aws lambda publish-layer-version \
    --layer-name "better-sqlite3-lambda-layer" \
    --description "Lambda layer for better-sqlite3 nodejs library" \
    --license "MIT" \
    --compatible-runtimes "nodejs8.10" \
    --zip-file "fileb://${PACKAGE_ZIP}"
