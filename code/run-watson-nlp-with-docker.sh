#!/bin/bash

# **************** Global variables
source ./.env

# Information on c
IMAGE_REGISTRY=${IMAGE_REGISTRY:-"cp.icr.io/cp/ai"}
RUNTIME_IMAGE=${RUNTIME_IMAGE:-"watson-nlp-runtime:1.0.20"}
export MODELS="${MODELS:-"watson-nlp_syntax_izumo_lang_en_stock:1.0.7,watson-nlp_syntax_izumo_lang_fr_stock:1.0.7"}"
IFS=',' read -ra models_arr <<< "${MODELS}"
TLS_CERT=${TLS_CERT:-""}
TLS_KEY=${TLS_KEY:-""}
CA_CERT=${CA_CERT:-""}
RUNTIME_CONTAINER_NAME=watson-nlp-with-models
MODEL_CONTAINERS_NAME=watson-nlp-models

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

function listModelArray () {

    echo ""
    echo "# ******"
    echo "# List model array content"
    echo "# ******"
    echo ""

    i=0
    for model in "${models_arr[@]}"
    do
      echo "Model $i : $model"
      i=$((i+1))
    done
}

function verifyKeysAndCerts () {
    
    echo ""
    echo "# ******"
    echo "# If TLS credentials are set up, run with TLS"
    echo "# ******"
    echo ""

    tls_args=""
    if [ "$TLS_CERT" != "" ] && [ "$TLS_KEY" != "" ]
    then
        echo "# Running with TLS"
        tls_args="$tls_args -v $(real_path ${TLS_KEY}):/tls/server.key.pem"
        tls_args="$tls_args -e TLS_SERVER_KEY=/tls/server.key.pem"
        tls_args="$tls_args -e SERVE_KEY=/tls/server.key.pem"
        tls_args="$tls_args -v $(real_path ${TLS_CERT}):/tls/server.cert.pem"
        tls_args="$tls_args -e TLS_SERVER_CERT=/tls/server.cert.pem"
        tls_args="$tls_args -e SERVE_CERT=/tls/server.cert.pem"
        tls_args="$tls_args -e PROXY_CERT=/tls/server.cert.pem"

        if [ "$CA_CERT" != "" ]
        then
            echo "# Enabling mTLS"
            tls_args="$tls_args -v $(real_path ${CA_CERT}):/tls/ca.cert.pem"
            tls_args="$tls_args -e TLS_CLIENT_CERT=/tls/ca.cert.pem"
            tls_args="$tls_args -e MTLS_CLIENT_CA=/tls/ca.cert.pem"
            tls_args="$tls_args -e PROXY_MTLS_KEY=/tls/server.key.pem"
            tls_args="$tls_args -e PROXY_MTLS_CERT=/tls/server.cert.pem"
        fi

        echo "TLS args: [$tls_args]"
    else 
        echo "TLS is not configured"
    fi
}

function createVolumeForModels() {
    
    echo ""
    echo "# ******"
    echo "# Create volume for models"
    echo "# ******"
    echo ""

    echo "# 1. Clear out existing volume"
    docker volume rm model_data 2>/dev/null || true

    echo "# 2. Create a shared volume and initialize with open permissions"
    docker volume create --label model_data
    echo "# 3. Run a container in an interactive mode to set the permissions"
    docker run --rm --name $MODEL_CONTAINERS_NAME -it -v model_data:/model_data alpine chmod 777 /model_data

    echo "# 4. Put models into the shared volume"
    i=0
    for model in "${models_arr[@]}"
    do
        docker run --rm --name $MODEL_CONTAINERS_NAME -it -v model_data:/app/models -e ACCEPT_LICENSE=true $IMAGE_REGISTRY/$model
        echo "Load model model: $model $i"
        i=$((i+1))
    done
}

function runNLPwithModels () {

    echo ""
    echo "# ******"
    echo "# Run NLP"
    echo "# ******"
    echo ""  
    echo "# Run the runtime with the models mounted"
    echo "" 
    docker run ${@} \
      --rm -it \
      -v model_data:/app/model_data \
      -e ACCEPT_LICENSE=true \
      -e LOCAL_MODELS_DIR=/app/model_data \
      -p 8085:8085 \
      -p 8080:8080 \
      --name $RUNTIME_CONTAINER_NAME \
      $tls_args $IMAGE_REGISTRY/$RUNTIME_IMAGE 
}

#**********************************************************************************
# Execution
# *********************************************************************************

listModelArray

verifyKeysAndCerts

connectToIBMContainerRegistry

createVolumeForModels

runNLPwithModels

