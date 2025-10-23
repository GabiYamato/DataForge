#!/usr/bin/env bash
set -euo pipefail

ARTIFACT="dist/ingestion.zip"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rm -f "${ROOT_DIR}/${ARTIFACT}"
mkdir -p "${ROOT_DIR}/dist"

python3 -m venv "${ROOT_DIR}/.venv-build"
source "${ROOT_DIR}/.venv-build/bin/activate"
pip install --upgrade pip
pip install -r "${ROOT_DIR}/requirements.txt"

pushd "${ROOT_DIR}" >/dev/null
zip -r "${ARTIFACT}" app.py -x "*.pyc"
SITE_PACKAGES="$(python -c 'import site; print(site.getsitepackages()[0])')"
pushd "${SITE_PACKAGES}" >/dev/null
zip -r9 "${ROOT_DIR}/${ARTIFACT}" jsonschema boto3 botocore dateutil urllib3 s3transfer six -x "*.dist-info*" >/dev/null
popd >/dev/null
popd >/dev/null

deactivate
rm -rf "${ROOT_DIR}/.venv-build"

echo "Packaged Lambda artifact at ${ROOT_DIR}/${ARTIFACT}"
