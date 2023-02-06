#!/bin/bash

# **************** Global variables
source ./.env

# Information
IMAGE_REGISTRY="cp.icr.io/cp/ai"
RUNTIME_IMAGE="watson-nlp-runtime"
WATSON_NLP_TAG="1.0.20"
#WATSON_NLP_TAG="1.0.18"
export WATSON_RUNTIME_BASE="$IMAGE_REGISTRY/$RUNTIME_IMAGE:$WATSON_NLP_TAG"
RUNTIME_CONTAINER_NAME=watson-nlp-with-custom-models
MODEL_CONTAINERS_NAME=watson-nlp-custom-models
TEMP_MODEL_DIR=models

######### Create custom Watson NLP image ##############
CUSTOM_WATSON_NLP_IMAGE_NAME=watson-nlp-runtime-with-custom-models
CUSTOM_TAG=1.0.0

# **********************************************************************************
# Functions definition
# **********************************************************************************

function connectToIBMContainerRegistry () {
    echo ""
    echo "# ******"
    echo "# Connect to IBM Cloud Container Image Registry: $IMAGE_REGISTRY"
    echo "# ******"
    echo ""
    echo "IBM_ENTITLEMENT_KEY: $IBM_ENTITLEMENT_KEY"
    echo ""
    docker login cp.icr.io --username cp --password $CONTAINER_ENTITLEMENT_KEY
}

function createCustomContainerImageLocally () {
    echo ""
    echo "# ******"
    echo "# Create container image"
    echo "# Runtime container image: $WATSON_RUNTIME_BASE"
    echo "# ******"
    echo ""
    echo "Image name: $CUSTOM_WATSON_NLP_IMAGE_NAME"
    docker build --build-arg WATSON_RUNTIME_BASE="$WATSON_RUNTIME_BASE" ./Multistage.Dockerfile -t "$CUSTOM_WATSON_NLP_IMAGE_NAME":"$CUSTOM_TAG"
}

function runNLPwithCustomModels () {

    echo ""
    echo "# ******"
    echo "# Run NLP with custom model"
    echo "# ******"
    echo ""  
    echo "# Run the custom runtime with the custom models mounted"
    echo "# Image: $IMAGE_REGISTRY/$RUNTIME_IMAGE"
    echo "" 
    docker run --rm -it \
      -e ACCEPT_LICENSE=true \
      -p 8085:8085 \
      -p 8080:8080 \
      --name $RUNTIME_CONTAINER_NAME \
      $CUSTOM_WATSON_NLP_IMAGE_NAME:$CUSTOM_TAG
}

#**********************************************************************************
# Execution
# *********************************************************************************

connectToIBMContainerRegistry 

createCustomContainerImageLocally

runNLPwithCustomModels
