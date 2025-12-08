#!/bin/bash
set -euo pipefail

# Package and publish Helm chart to OCI registry

# Change to working directory if specified
if [ -n "${WORKING_DIR}" ] && [ "${WORKING_DIR}" != "." ]; then
    cd "${WORKING_DIR}"
fi

# Get chart name from Chart.yaml
CHART_NAME=$(grep '^name:' "${CHART_PATH}/Chart.yaml" | awk '{print $2}' | tr -d '"')

if [ -z "${CHART_NAME}" ]; then
    echo "❌ Error: Could not extract chart name from Chart.yaml"
    exit 1
fi

echo "📦 Packaging Helm chart: ${CHART_NAME}"
echo "   Version: ${VERSION}"
echo "   Registry: ${REGISTRY}"

# Update dependencies if requested
if [ "${UPDATE_DEPS}" = "true" ]; then
    echo "🔄 Updating chart dependencies..."
    helm dependency update "${CHART_PATH}"
fi

# Create a temp directory for packaging
PACKAGE_DIR=$(mktemp -d)
trap "rm -rf ${PACKAGE_DIR}" EXIT

# Package the chart
echo "📦 Packaging chart..."
helm package "${CHART_PATH}" -d "${PACKAGE_DIR}"

# Find the packaged file
CHART_FILE="${PACKAGE_DIR}/${CHART_NAME}-${VERSION}.tgz"

if [ ! -f "${CHART_FILE}" ]; then
    echo "❌ Error: Packaged chart not found at ${CHART_FILE}"
    echo "Files in package directory:"
    ls -la "${PACKAGE_DIR}"
    exit 1
fi

echo "✅ Chart packaged: ${CHART_FILE}"

# Login to registry
echo "🔐 Logging in to ${REGISTRY}..."
echo "${GITHUB_TOKEN}" | helm registry login "${REGISTRY%%/*}" -u "${GITHUB_ACTOR}" --password-stdin

# Push to OCI registry
echo "🚀 Pushing chart to OCI registry..."
helm push "${CHART_FILE}" "oci://${REGISTRY}"

# Set outputs
CHART_URL="${REGISTRY}/${CHART_NAME}:${VERSION}"
echo "chart-url=${CHART_URL}" >> $GITHUB_OUTPUT
echo "chart-file=${CHART_FILE}" >> $GITHUB_OUTPUT
echo "chart-name=${CHART_NAME}" >> $GITHUB_OUTPUT

echo ""
echo "✅ Successfully published Helm chart!"
echo "📦 Chart URL: ${CHART_URL}"
echo "🏷️  Version: ${VERSION}"
