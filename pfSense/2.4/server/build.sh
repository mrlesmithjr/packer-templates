#! /usr/bin/env bash
TEMPLATE="template.json"
ISO_DL_URL=$(jq -r .iso_dl_url $TEMPLATE)
ISO_DL_CHECKSUM=$(jq -r .iso_dl_checksum $TEMPLATE)
ISO_CHECKSUM_TYPE=$(jq -r .iso_checksum_type $TEMPLATE | sed 's/sha//g')
ISO_FILENAME_GZ=$(basename $ISO_DL_URL)
ISO_FILENAME=$(echo $ISO_FILENAME_GZ | sed 's/.gz//g')
if [ ! -f $ISO_FILENAME ]; then
  if [ ! -f $ISO_FILENAME_GZ ]; then
    wget $ISO_DL_URL
  fi
  ISO_FILENAME_GZ_SHA=$(shasum -a $ISO_CHECKSUM_TYPE $ISO_FILENAME_GZ | awk '{ print $1 }')
  if [ $ISO_FILENAME_GZ_SHA == $ISO_DL_CHECKSUM ]; then
    gunzip $ISO_FILENAME_GZ
  fi
fi
ISO_SHA=$(shasum -a $ISO_CHECKSUM_TYPE $ISO_FILENAME | awk '{ print $1 }')
sed -i '' "s/replace_iso_checksum/$ISO_SHA/g" "$TEMPLATE"
sed -i '' "s/replace_iso_url/$ISO_FILENAME/g" "$TEMPLATE"
packer build -only=virtualbox-iso -var-file=../../../private_vars.json -var-file=box_info.json -var-file=template.json ../../pfsense-server.json
# sed -i '' "s/$ISO_SHA/replace_iso_checksum/g" "$TEMPLATE"
# sed -i '' "s/$ISO_FILENAME/replace_iso_url/1" "$TEMPLATE"
