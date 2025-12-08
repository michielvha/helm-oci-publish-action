#!/bin/bash
set -euo pipefail

# Update Chart.yaml with version

# Change to working directory if specified
if [ -n "${WORKING_DIR}" ] && [ "${WORKING_DIR}" != "." ]; then
    cd "${WORKING_DIR}"
fi

CHART_YAML="${CHART_PATH}/Chart.yaml"

if [ ! -f "${CHART_YAML}" ]; then
    echo "❌ Error: Chart.yaml not found at ${CHART_YAML}"
    exit 1
fi

echo "📝 Updating Chart.yaml in ${CHART_PATH}"
echo "   Version: ${VERSION}"

# Update chart version
sed -i.bak "s/^version:.*/version: ${VERSION}/" "${CHART_YAML}"

# Update appVersion if provided
if [ -n "${APP_VERSION}" ]; then
    echo "   App Version: ${APP_VERSION}"
    sed -i.bak "s/^appVersion:.*/appVersion: \"${APP_VERSION}\"/" "${CHART_YAML}"
else
    # If not provided, use chart version
    echo "   App Version: ${VERSION} (same as chart version)"
    sed -i.bak "s/^appVersion:.*/appVersion: \"${VERSION}\"/" "${CHART_YAML}"
fi

# Remove backup file
rm -f "${CHART_YAML}.bak"

echo "✅ Chart.yaml updated successfully"
echo ""
echo "Updated Chart.yaml:"
grep -E "^(version|appVersion):" "${CHART_YAML}"
