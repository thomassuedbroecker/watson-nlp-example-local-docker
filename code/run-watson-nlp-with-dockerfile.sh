#!/bin/bash

# **************** Global variables
source ./.env

# Information
IMAGE_REGISTRY="cp.icr.io/cp/ai"
RUNTIME_IMAGE="watson-nlp-runtime"
WATSON_NLP_TAG="1.0.20"
#WATSON_NLP_TAG="1.0.18"
export WATSON_RUNTIME_BASE="$IMAGE_REGISTRY/$RUNTIME_IMAGE:$WATSON_NLP_TAG"
export MODELS="${MODELS:-"watson-nlp_syntax_izumo_lang_en_stock:1.0.7,watson-nlp_syntax_izumo_lang_fr_stock:1.0.7"}"
RUNTIME_CONTAINER_NAME=watson-nlp-with-custom-models
MODEL_CONTAINERS_NAME=watson-nlp-custom-models
TEMP_MODEL_DIR=models
DOWNLOAD_IMAGE=alpine

######### Create custom Watson NLP image ##############
CUSTOM_WATSON_NLP_IMAGE_NAME=watson-nlp-runtime-with-custom-models
CUSTOM_TAG=1.0.2

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

function listPretrainedModelArray () {

    echo ""
    echo "# ******"
    echo "# List pretrained model array content"
    echo "# ******"
    echo ""
    
    echo "1. Load pretrained model array array"
    IFS=',' read -ra models_arr <<< "${MODELS}"

    echo "2. List pretrained models"
    i=0
    for model in "${models_arr[@]}"
    do
      echo "Model $i : $model"
      i=$((i+1))
    done
}

function downloadThePretrainedModels() {
    
    echo ""
    echo "# ******"
    echo "# Download the pretrained models"
    echo "# ******"
    echo ""

    HOME_TMP=$(pwd)
    mkdir $(pwd)/$TEMP_MODEL_DIR

    echo "# 1. Run a container in an interactive mode to set the permissions"
    docker run --rm --name $MODEL_CONTAINERS_NAME -it -v "$(pwd)/$TEMP_MODEL_DIR":/model_data $DOWNLOAD_IMAGE chmod 777 /model_data

    echo "# 2. Put models into the file share"
    i=0
    for model in "${models_arr[@]}"
    do
        docker run --rm --name $MODEL_CONTAINERS_NAME -it -v "$(pwd)/app/models":/app/models -e ACCEPT_LICENSE=true $IMAGE_REGISTRY/$model
        i=$((i+1))
        echo "Download model: $i $MODEL_CONTAINERS_NAME $IMAGE_REGISTRY/$model"
    done
}

function createCustomContainerImageLocally () {
    echo ""
    echo "# ******"
    echo "# Create container image"
    echo "# Runtime container image: $WATSON_RUNTIME_BASE"
    echo "# ******"
    echo ""
    echo "Image name: $CUSTOM_WATSON_NLP_IMAGE_NAME"
    docker build --build-arg WATSON_RUNTIME_BASE="$WATSON_RUNTIME_BASE" ./ -t "$CUSTOM_WATSON_NLP_IMAGE_NAME":"$CUSTOM_TAG"
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

listPretrainedModelArray

downloadThePretrainedModels

createCustomContainerImageLocally

runNLPwithCustomModels
