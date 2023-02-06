# Using the Docker container image for model

ARG WATSON_RUNTIME_BASE
ARG PRETRAINED_MODEL="cp.icr.io/cp/ai/watson-nlp_sentiment_aggregated-cnn-workflow_lang_en_stock:1.0.6"
ARG CUSTOM_MODEL="us.icr.io/custom-watson-nlp-tsued/watson-nlp_ensemble_model:1.0.0"

# ****************************
# BUILD: Prepare and unpacked models inside a container
# ****************************
FROM ${PRETRAINED_MODEL} as pretrained
RUN ./unpack_model.sh

FROM ${CUSTOM_MODEL} as custom
RUN ./unpack_model.sh

# ****************************
# PRODUCTION: Runtime with unpacked models
# ****************************
FROM ${WATSON_RUNTIME_BASE} as release

RUN true && \
    mkdir -p /app/models

ENV LOCAL_MODELS_DIR=/app/models
# COPY --from=pretrained app/models /app/models
COPY --from=custom app/models /app/models
