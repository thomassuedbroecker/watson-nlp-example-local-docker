# Run Watson NLP for Embed on your local computer with Docker

This is an example about, how to use Watson NLP based on the official example documentation:[IBM Watson Libraries for Embed](https://www.ibm.com/docs/en/watson-libraries?topic=watson-natural-language-processing-library-embed-home).

> Visit the related blog post [`Run Watson NLP for Embed on your local computer with Docker`](https://suedbroecker.net/2022/12/15/run-watson-nlp-for-embed-on-your-local-computer-with-docker/).


## Pretrained models

### Step 1: Clone the example project to your local computer

```sh
git clone https://github.com/thomassuedbroecker/watson-nlp-example-local-docker
cd watson-nlp-example-local-docker/code
```

### Step 2:  Set your IBM_ENTITLEMENT_KEY in the `.env` file

```sh
cat .env_template > .env
```

Edit the `.env` file.

```sh
# used as 'environment' variables
IBMCLOUD_ENTITLEMENT_KEY="YOUR_KEY"
```

### Step 3: Execute the `run-watson-nlp-with-docker.sh` bash script

```sh
sh run-watson-nlp-with-docker.sh
```

* Example output:

```sh
# ******
# List model array content
# ******

Model 0 : watson-nlp_syntax_izumo_lang_en_stock:1.0.7
Model 1 : watson-nlp_syntax_izumo_lang_fr_stock:1.0.7

# ******
# If TLS credentials are set up, run with TLS
# ******

TLS is not configured

# ******
# Connect to IBM Cloud Container Image Registry: cp.icr.io/cp/ai
# ******

IBM_ENTITLEMENT_KEY: XXXX

flag needs an argument: --password

# ******
# Create volume for models
# ******

# 1. Clear out existing volume
model_data
# 2. Create a shared volume and initialize with open permissions
0741b26b357dc5a5fc0c002a6ed9da0cf2373c13e5a4f644b850cdc47bd9b3bc
# 3. Run a container in an interactive mode to set the permissions
# 4. Put models into the shared volume
Archive:  /app/model.zip
  inflating: config.yml              
Load model model: watson-nlp_syntax_izumo_lang_en_stock:1.0.7 0
Archive:  /app/model.zip
  inflating: config.yml              
Load model model: watson-nlp_syntax_izumo_lang_fr_stock:1.0.7 1

# ******
# Run NLP
# ******

# Run the runtime with the models mounted

[STARTING RUNTIME]

....

10001001I>", "message": "Common Service is running on port: 8085 with thread pool size: 5", "num_indent": 0, "thread_id": 140231246393600, "timestamp": "2022-12-15T17:18:13.453967"}
[STARTING GATEWAY]
2022/12/15 17:18:14 Running with INSECURE credentials
2022/12/15 17:18:14 Serving proxy calls INSECURE
```

### Step 4: Verify running Watson NLP container

Verify the running Watson NLP container by open a new terminal session and execute an API call.

* Models 
    * **syntax_izumo_lang_en_stock**
    * **syntax_izumo_lang_fr_stock**

* Text
    * _This is a test sentence_
    * _Ceci est une phrase test_

```sh
 curl -s \
   "http://localhost:8080/v1/watson.runtime.nlp.v1/NlpService/SyntaxPredict" \
   -H "accept: application/json" \
   -H "content-type: application/json" \
   -H "grpc-metadata-mm-model-id: syntax_izumo_lang_fr_stock" \
   -d '{ "raw_document": { "text": "Ceci est une phrase test" }, "parsers": ["token"] }'
```

* Example output:

```json
{"text":"This is a test sentence", "producerId":{"name":"Izumo Text Processing", "version":"0.0.1"}, "tokens":[{"span":{"begin":0, "end":4, "text":"This"}, "lemma":"", "partOfSpeech":"POS_UNSET", "dependency":null, "features":[]}, {"span":{"begin":5, "end":7, "text":"is"}, "lemma":"", "partOfSpeech":"POS_UNSET", "dependency":null, "features":[]}, {"span":{"begin":8, "end":9, "text":"a"}, "lemma":"", "partOfSpeech":"POS_UNSET", "dependency":null, "features":[]}, {"span":{"begin":10, "end":14, "text":"test"}, "lemma":"", "partOfSpeech":"POS_UNSET", "dependency":null, "features":[]}, {"span":{"begin":15, "end":23, "text":"sentence"}, "lemma":"", "partOfSpeech":"POS_UNSET", "dependency":null, "features":[]}], "sentences":[{"span":{"begin":0, "end":23, "text":"This is a test sentence"}}], "paragraphs":[{"span":{"begin":0, "end":23, "text":"This is a test sentence"}}]}
```

We executed the syntac predict [v1/watson.runtime.nlp.v1/NlpService/SyntaxPredict](https://developer.ibm.com/apis/catalog/embeddableai--watson-natural-language-processing-apis/api/API--embeddableai--watson-natural-language-processing-apis#SyntaxPredict) REST API methode and the `syntax_izumo_lang_en_stock` model.

## Custom model and pretrained models

### Step 1: Follow the steps to create a custom classification model

Visit the [Customize a classification model for Watson NLP for Embed](https://github.com/thomassuedbroecker/watson-nlp-custom-model#customize-a-classification-model-for-watson-nlp-for-embed)


### Step 2: Clone the example project to your local computer

```sh
git clone https://github.com/thomassuedbroecker/watson-nlp-example-local-docker
cd watson-nlp-example-local-docker/code
```

### Step 3:  Set your IBM_ENTITLEMENT_KEY in the `.env` file

```sh
cat .env_template > .env
```

Edit the `.env` file.

```sh
# used as 'environment' variables
IBMCLOUD_ENTITLEMENT_KEY="YOUR_KEY"
```

### Step 4: Copy the created model

Ensure you copied the your custom model to this folder.

```sh
code/app/custom_models
```

### Step 5: Execute the `run-watson-nlp-with-docker.sh` bash script

```sh
sh run-watson-nlp-with-dockerfile.sh
```

* Example output:

```sh
# ******
# Connect to IBM Cloud Container Image Registry: cp.icr.io/cp/ai
# ******

IBM_ENTITLEMENT_KEY: 
XXXX

# ******
# List pretrained model array content
# ******

1. Load pretrained model array array
2. List pretrained models
Model 0 : watson-nlp_syntax_izumo_lang_en_stock:1.0.7
Model 1 : watson-nlp_syntax_izumo_lang_fr_stock:1.0.7

# ******
# Download the pretrained models
# ******

mkdir: /Users/thomassuedbroecker/Downloads/dev/watson-nlp-example-local-docker/code/models: File exists
# 1. Run a container in an interactive mode to set the permissions
# 2. Put models into the file share
Archive:  /app/model.zip
...

# ******
# Create container image
# Runtime container image: cp.icr.io/cp/ai/watson-nlp-runtime:1.0.20
# ******

Image name: watson-nlp-runtime-with-custom-models
[+] Building 19.3s (8/8) FINISHED                                                         
 => [internal] load build definition from Dockerfile                                 0.0s
 => => transferring dockerfile: 203B                                                 0.0s
 => [internal] load .dockerignore                                                    0.0s
 => => transferring context: 2B                                                      0.0s
 => [internal] load metadata for cp.icr.io/cp/ai/watson-nlp-runtime:1.0.20           0.0s
 => [1/3] FROM cp.icr.io/cp/ai/watson-nlp-runtime:1.0.20                             0.0s
 => [internal] load build context                                                   12.4s
 => => transferring context: 1.27GB                                                 12.0s
 => CACHED [2/3] COPY ./app/models /app/models                                       0.0s
 => [3/3] COPY ./app/custom_models /app/models                                       2.0s
 => exporting to image                                                               4.8s
 => => exporting layers                                                              4.8s
 => => writing image sha256:4bb2f8d4cc35bff3f6e38c645d47ae30d53fc024ccb56274b439318  0.0s
 => => naming to docker.io/library/watson-nlp-runtime-with-custom-models:1.0.0       0.0s

...

# ******
# Run NLP with custom model
# ******

# Run the custom runtime with the custom models mounted
# Image: cp.icr.io/cp/ai/watson-nlp-runtime

[STARTING RUNTIME]
WARNING:root:Limited tf.compat.v2.summary API due to missing TensorBoard installation.
...
{"channel": "COMMON-SERVR", "exception": null, "level": "info", "log_code": "<COM10001001I>", "message": "Common Service is running on port: 8085 with thread pool size: 5", "num_indent": 0, "thread_id": 140369309888768, "timestamp": "2023-01-31T09:22:04.343563"}
[STARTING GATEWAY]
2023/01/31 09:22:05 Running with INSECURE credentials
2023/01/31 09:22:05 Serving proxy calls INSECURE
```

### Step 6: Open a new terminal and insert following `curl` command

```sh
curl -s -X POST "http://localhost:8080/v1/watson.runtime.nlp.v1/NlpService/ClassificationPredict" \
  -H "accept: application/json" \
  -H "grpc-metadata-mm-model-id: ensemble_model" \
  -H "content-type: application/json" \
  -d "{ \"rawDocument\": \
    { \"text\": \"The credit card doesn't work, and I look at the savings, but I need more money to spend.\" }}" | jq
```

* Example output:

```sh
{
  "classes": [
    {
      "className": "Credit reporting, credit repair services, or other personal consumer reports",
      "confidence": 0.35304376
    },
    {
      "className": "Credit card or prepaid card",
      "confidence": 0.273138
    },
    {
      "className": "Debt collection",
      "confidence": 0.114369996
    },
    {
      "className": "Checking or savings account",
      "confidence": 0.07278225
    },
    {
      "className": "Mortgage",
      "confidence": 0.050865967
    }
  ],
  "producerId": {
    "name": "Voting based Ensemble",
    "version": "0.0.1"
  }
}
```
