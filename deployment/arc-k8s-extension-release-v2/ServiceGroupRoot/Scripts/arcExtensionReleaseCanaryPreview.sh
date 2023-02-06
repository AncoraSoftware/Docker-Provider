#!/bin/bash
# Register azuremonitor-containers extension with Arc Registration API
export HELM_EXPERIMENTAL_OCI=1

REGISTER_REGIONS_CANARY=$REGISTER_REGIONS_CANARY
RELEASE_TRAINS_PREVIEW_PATH=${RELEASE_TRAINS_PREVIEW_PATH}
RELEASE_TRAINS_STABLE_PATH=${RELEASE_TRAINS_STABLE_PATH}
REGISTER_REGIONS_BATCH=($REGISTER_REGIONS_BATCH)
IS_CUSTOMER_HIDDEN=$IS_CUSTOMER_HIDDEN
CHART_VERSION=${CHART_VERSION}

PACKAGE_CONFIG_NAME="${PACKAGE_CONFIG_NAME:-microsoft.azuremonitor.containers-pkg022022}"
API_VERSION="${API_VERSION:-2021-05-01}"
METHOD="${METHOD:-put}"
REGISTRY_PATH_CANARY_PREVIEW="https://mcr.microsoft.com/azuremonitor/containerinsights/canary/preview/azuremonitor-containers"
REGISTRY_PATH_CANARY_STABLE="https://mcr.microsoft.com/azuremonitor/containerinsights/canary/stable/azuremonitor-containers"
REGISTRY_PATH_PROD_STABLE="https://mcr.microsoft.com/azuremonitor/containerinsights/prod1/stable/azuremonitor-containers"

if [ -z "$REGISTER_REGIONS_CANARY" ]; then
    echo "-e error release region must be provided "
    exit 1
fi
if [ -z "$IS_CUSTOMER_HIDDEN" ]; then
    echo "-e error is_customer_hidden must be provided "
    exit 1
fi
if [ -z "$CHART_VERSION" ]; then
    echo "-e error chart version must be provided "
    exit 1
fi

MCR_NAME_PATH="mcr.microsoft.com/azuremonitor/containerinsights/canary/preview/azuremonitor-containers"
echo "Pulling chart from MCR:${MCR_NAME_PATH}"
helm chart pull ${MCR_NAME_PATH}:${CHART_VERSION}
if [ $? -eq 0 ]; then
  echo "Pulling chart from MCR:${MCR_NAME_PATH}:${CHART_VERSION} completed successfully."
else
  echo "-e error Pulling chart from MCR:${MCR_NAME_PATH}:${CHART_VERSION} failed. Please review Ev2 pipeline logs for more details on the error."
  #exit 1
fi   

echo "Start arc extension release stage ${RELEASE_STAGE}, REGISTER_REGIONS is $REGISTER_REGIONS_CANARY, RELEASE_TRAINS are $RELEASE_TRAINS_PREVIEW_PATH, $RELEASE_TRAINS_STABLE_PATH, PACKAGE_CONFIG_NAME is $PACKAGE_CONFIG_NAME, API_VERSION is $API_VERSION, METHOD is $METHOD"

case $RELEASE_STAGE in

  CanaryPreview)
if [ -z "$RELEASE_TRAINS_PREVIEW_PATH" ]; then
    echo "-e error preview release train must be provided "
    exit 1
fi
# Create JSON request body
cat <<EOF > "request.json"
{
    "artifactEndpoints": [
        {
            "Regions": [
                $REGISTER_REGIONS_CANARY
            ],
            "Releasetrains": [
                $RELEASE_TRAINS_PREVIEW_PATH
            ],
            "FullPathToHelmChart": "$REGISTRY_PATH_CANARY_PREVIEW",
            "ExtensionUpdateFrequencyInMinutes": 60,
            "IsCustomerHidden": $IS_CUSTOMER_HIDDEN,
            "ReadyforRollout": true,
            "RollbackVersion": null,
            "PackageConfigName": "$PACKAGE_CONFIG_NAME"
        },
EOF
sed -i '$ s/.$//' request.json
cat <<EOF >> "request.json"
    ]
}
EOF
    ;;

  CanaryStable)
if [ -z "$RELEASE_TRAINS_PREVIEW_PATH" ]; then
    echo "-e error preview release train must be provided "
    exit 1
fi
if [ -z "$RELEASE_TRAINS_STABLE_PATH" ]; then
    echo "-e error stable release train must be provided "
    exit 1
fi
# Create JSON request body
cat <<EOF > "request.json"
{
    "artifactEndpoints": [
        {
            "Regions": [
                $REGISTER_REGIONS_CANARY
            ],
            "Releasetrains": [
                $RELEASE_TRAINS_PREVIEW_PATH
            ],
            "FullPathToHelmChart": "$REGISTRY_PATH_CANARY_PREVIEW",
            "ExtensionUpdateFrequencyInMinutes": 60,
            "IsCustomerHidden": $IS_CUSTOMER_HIDDEN,
            "ReadyforRollout": true,
            "RollbackVersion": null,
            "PackageConfigName": "$PACKAGE_CONFIG_NAME"
        },
EOF
cat <<EOF >> "request.json"
        {
            "Regions": [
                $REGISTER_REGIONS_CANARY
            ],
            "Releasetrains": [
                $RELEASE_TRAINS_STABLE_PATH
            ],
            "FullPathToHelmChart": "$REGISTRY_PATH_CANARY_STABLE",
            "ExtensionUpdateFrequencyInMinutes": 60,
            "IsCustomerHidden": $IS_CUSTOMER_HIDDEN,
            "ReadyforRollout": true,
            "RollbackVersion": null,
            "PackageConfigName": "$PACKAGE_CONFIG_NAME"
        },
EOF
sed -i '$ s/.$//' request.json
cat <<EOF >> "request.json"
    ]
}
EOF
    ;;

  Stable)
if [ -z "$RELEASE_TRAINS_PREVIEW_PATH" ]; then
    echo "-e error preview release train must be provided "
    exit 1
fi
if [ -z "$RELEASE_TRAINS_STABLE_PATH" ]; then
    echo "-e error stable release train must be provided "
    exit 1
fi
if [ -z "$REGISTER_REGIONS_BATCH" ]; then
    echo "-e error stable release train must be provided "
    exit 1
fi
# Create JSON request body
cat <<EOF > "request.json"
{
    "artifactEndpoints": [
        {
            "Regions": [
                $REGISTER_REGIONS_CANARY
            ],
            "Releasetrains": [
                $RELEASE_TRAINS_PREVIEW_PATH
            ],
            "FullPathToHelmChart": "$REGISTRY_PATH_CANARY_PREVIEW",
            "ExtensionUpdateFrequencyInMinutes": 60,
            "IsCustomerHidden": $IS_CUSTOMER_HIDDEN,
            "ReadyforRollout": true,
            "RollbackVersion": null,
            "PackageConfigName": "$PACKAGE_CONFIG_NAME"
        },
EOF
cat <<EOF >> "request.json"
        {
            "Regions": [
                $REGISTER_REGIONS_CANARY
            ],
            "Releasetrains": [
                $RELEASE_TRAINS_STABLE_PATH
            ],
            "FullPathToHelmChart": "$REGISTRY_PATH_CANARY_STABLE",
            "ExtensionUpdateFrequencyInMinutes": 60,
            "IsCustomerHidden": $IS_CUSTOMER_HIDDEN,
            "ReadyforRollout": true,
            "RollbackVersion": null,
            "PackageConfigName": "$PACKAGE_CONFIG_NAME"
        },
EOF
cat <<EOF >> "request.json"
        {
            "Regions": [
                $REGISTER_REGIONS_BATCH
            ],
            "Releasetrains": [
                $RELEASE_TRAINS_STABLE_PATH
            ],
            "FullPathToHelmChart": "$REGISTRY_PATH_PROD_STABLE",
            "ExtensionUpdateFrequencyInMinutes": 60,
            "IsCustomerHidden": $IS_CUSTOMER_HIDDEN,
            "ReadyforRollout": true,
            "RollbackVersion": null,
            "PackageConfigName": "$PACKAGE_CONFIG_NAME"
        },
EOF
sed -i '$ s/.$//' request.json
cat <<EOF >> "request.json"
    ]
}
EOF
    ;;
    
  *)
    echo -n "unknown release stage"
    exit 1
    ;;
esac

cat request.json | jq

# Send Request
SUBSCRIPTION=${ADMIN_SUBSCRIPTION_ID}
RESOURCE_AUDIENCE=${RESOURCE_AUDIENCE}

#Login to az cli and authenticate to acr
echo "Login cli using managed identity"
az login --identity
if [ $? -eq 0 ]; then
  echo "Logged in successfully with msi"
else
  echo "-e error az login with managed identity credentials failed. Please review the Ev2 pipeline logs for more details on the error."
  exit 1
fi

ACCESS_TOKEN=$(az account get-access-token --resource $RESOURCE_AUDIENCE --query accessToken -o json)
if [ $? -eq 0 ]; then
  echo "get access token from resource:$RESOURCE_AUDIENCE successfully."
else
  echo "-e error get access token from resource:$RESOURCE_AUDIENCE failed. Please review Ev2 pipeline logs for more details on the error."
  exit 1
fi   
ACCESS_TOKEN=$(echo $ACCESS_TOKEN | tr -d '"' | tr -d '"\r\n')

ARC_API_URL="https://eastus2euap.dp.kubernetesconfiguration.azure.com"
EXTENSION_NAME="microsoft.azuremonitor.containers"
echo "Request parameter preparation, SUBSCRIPTION is $SUBSCRIPTION, RESOURCE_AUDIENCE is $RESOURCE_AUDIENCE, CHART_VERSION is $CHART_VERSION"

echo "start send request"
az rest --method $METHOD --headers "{\"Authorization\": \"Bearer $ACCESS_TOKEN\", \"Content-Type\": \"application/json\"}" --body @request.json --uri $ARC_API_URL/subscriptions/$SUBSCRIPTION/extensionTypeRegistrations/$EXTENSION_NAME/versions/$CHART_VERSION?api-version=$API_VERSION
if [ $? -eq 0 ]; then
  echo "arc extension registered successfully"
else
  echo "-e error failed to register arc extension"
  exit 1
fi