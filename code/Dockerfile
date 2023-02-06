ARG WATSON_RUNTIME_BASE
FROM ${WATSON_RUNTIME_BASE} as base
ENV LOCAL_MODELS_DIR=/app/models

# Copy the images from the local machine.
# COPY ./app/models /app/models
COPY ./app/custom_models /app/models
