#!/usr/bin/env bash
set -o errexit
set -x

# Packages a helm chart and pushes it to a the Helm repository in S3.
# Also merges the generated index.yaml file with the existing one in the bucket.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUCKET_NAME="pochelmcharts"
export AWS_DEFAULT_REGION="us-east-1"

[[ -z "$1" ]] && { echo -e "Usage: $( basename $0 ) CHART_NAME\ne.g. $( basename $0 ) my-chart" ; exit 1; }

CHART_NAME=$1
CHART_PATH=${SCRIPT_DIR}/${CHART_NAME}

# Add repo
helm repo add poc s3://${BUCKET_NAME}

# Package chart
BUCKET_PATH="$( mktemp -d /tmp/helm_bucket_XXXXXXXXX )"
mkdir -p ${BUCKET_PATH}
helm package ${CHART_PATH} -d ${BUCKET_PATH}

# Generate index.yaml
# Pull index.yaml from s3 bucket
aws s3 cp s3://${BUCKET_NAME}/index.yaml ${BUCKET_PATH}/index_to_merge.yaml
helm repo index ${BUCKET_PATH} --url s3://${BUCKET_NAME}/ --merge ${BUCKET_PATH}/index_to_merge.yaml
rm -f ${BUCKET_PATH}/index_to_merge.yaml

# Sync to s3
aws s3 sync ${BUCKET_PATH} s3://${BUCKET_NAME}

# Clean up
rm -r ${BUCKET_PATH}

# Update chart cache
helm repo update