#! /usr/bin/env bash

# Manages Vagrant Cloud boxes/versions/providers

# set -e
# set -x

# BOX_INFO="box_info.json"
# PRIVATE_VARS="../../../private_vars.json"
# VAGRANT_CLOUD_TOKEN=$(jq -r .vagrant_cloud_token $PRIVATE_VARS)

# BOX_TAG=$(jq -r .box_tag $BOX_INFO)
# BOX_NAME=$(echo $BOX_TAG | awk -F/ '{ print $2 }')
# BOX_SHORT_DESCR=$(jq -r .short_description $BOX_INFO)
# USERNAME=$(echo $BOX_TAG | awk -F/ '{ print $1 }')

# for BOX in $(ls *.box)
# do
#     BOX_FULL_NAME=$(echo $BOX | awk -F. '{ print $1 }')
#     PROVIDER_NAME=$(echo $BOX_FULL_NAME | awk -F- '{ print $5 }')
#     VERSION=$(echo $BOX_FULL_NAME | awk -F- '{ print $6 }')

    # Moved to utils.py
    # Check if box exists
    # BOX_CHECK=$(curl -s \
    #     --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    # https://app.vagrantup.com/api/v1/box/$BOX_TAG)

    # BOX_CHECK_ERRORS=$(echo $BOX_CHECK | jq .errors)

    # if [[ $BOX_CHECK_ERRORS != null ]]; then
    #     # Create box if it does not exist
    #     echo -e "\n$BOX_TAG not found...Creating."
    #     CREATE_BOX=$(curl -s \
    #         --header "Content-Type: application/json" \
    #         --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    #         https://app.vagrantup.com/api/v1/boxes \
    #         --data '
    #         {
    #             "box": {
    #                 "username": "'"$USERNAME"'",
    #                 "name": "'"$BOX_NAME"'",
    #                 "is_private": false,
    #                 "short_description": "'"$BOX_SHORT_DESCR"'",
    #                 "description": "'"$BOX_SHORT_DESCR"'"
    #             }
    #         }
    #     ')
    # else
    #     # Update box
    #     echo -e "box: $BOX_TAG already exists...Skipping creation."
    #     echo -e "box: $BOX_TAG updating box info."
    #     UPDATE_BOX=$(curl -s \
    #         --header "Content-Type: application/json" \
    #         --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
    #         https://app.vagrantup.com/api/v1/box/$BOX_TAG \
    #         --request PUT \
    #         --data '
    #         {
    #             "box": {
    #                 "name": "'"$BOX_NAME"'",
    #                 "short_description": "'"$BOX_SHORT_DESCR"'",
    #                 "description": "'"$BOX_SHORT_DESCR"'",
    #                 "is_private": false
    #             }
    #         }
    #     ')
    # fi

#     # Check if version already exists
#     VERSION_CHECK=$(curl -s \
#         --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
#     https://app.vagrantup.com/api/v1/box/$BOX_TAG/version/$VERSION)

#     VERSION_CHECK_ERRORS=$(echo $VERSION_CHECK | jq -r .errors)

#     if [[ "${VERSION_CHECK_ERRORS[*]}" = *"Resource not found!"* ]]; then
#         # Create a new version
#         echo -e "\nCreating version $VERSION for $BOX_TAG"
#         curl -s \
#         --header "Content-Type: application/json" \
#         --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
#         https://app.vagrantup.com/api/v1/box/$BOX_TAG/versions \
#         --data '
#             {
#                 "version": {
#                     "version": "'"$VERSION"'"
#                 }
#             }
#         '
#     else
#         echo "box: $BOX_TAG version: $VERSION already exists...Skipping version."
#     fi

#     if [ ! -z "$VERSION_CHECK_ERRORS" ]; then
#         # Check for existing providers for version
#         PROVIDER_CHECK=$(curl -s \
#             --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
#         https://app.vagrantup.com/api/v1/box/$BOX_TAG/version/$VERSION)
#         PROVIDERS=$(echo $PROVIDER_CHECK | jq .providers)
#         PROVIDERS_FOUND=()
#         for PROVIDER in "${PROVIDERS[@]}"
#         do
#             PROVIDER_INFO=$(echo $PROVIDER | jq .[])
#             PROVIDER_INFO_NAME=$(echo $PROVIDER_INFO | jq -r .name)
#             PROVIDERS_FOUND+=($PROVIDER_INFO_NAME)
#         done
#         if [[ "${PROVIDERS_FOUND[*]}" = *"$PROVIDER_NAME"* ]]; then
#             echo -e "box: $BOX_TAG version: $VERSION provider: $PROVIDER_NAME already exists...Skipping provider."
#         else
#             # Create a new provider
#             echo -e "\nCreating box: $BOX_TAG version: $VERSION provider: $PROVIDER_NAME"
#             curl -s \
#             --header "Content-Type: application/json" \
#             --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
#             https://app.vagrantup.com/api/v1/box/$BOX_TAG/version/$VERSION/providers \
#             --data '
#             {
#                 "provider": {
#                     "name": "'"$PROVIDER_NAME"'"
#                     }
#             }
#             '

#             # Prepare the provider for upload/get an upload URL
#             echo -e "\nPreparing upload for box: $BOX_TAG version: $VERSION provider: $PROVIDER_NAME"
#             RESPONSE=$(curl -s \
#                 --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
#             https://app.vagrantup.com/api/v1/box/$BOX_TAG/version/$VERSION/provider/$PROVIDER_NAME/upload)

#             # Extract the upload URL from the response (requires the jq command)
#             UPLOAD_PATH=$(echo $RESPONSE | jq -r .upload_path)

#             # Perform the upload
#             echo -e "\nUploading box: $BOX_TAG version: $VERSION provider: $PROVIDER_NAME"
#             curl -s -X PUT --progress-bar --upload-file $BOX $UPLOAD_PATH | tee /dev/null

#             # Release the version
#             echo -e "\nReleasing box: $BOX_TAG version: $VERSION provider: $PROVIDER_NAME"
#             curl -s \
#             --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
#             https://app.vagrantup.com/api/v1/box/$BOX_TAG/version/$VERSION/release \
#             --request PUT
#         fi
#     fi
# done
