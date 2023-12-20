#/bin/sh

FIREBASE_CONFIG_NAME=GoogleService-Info.plist

# NOTE: This should only live on the file system and should NOT be part of the target (since we'll be adding them to the target manually)
FIREBASE_CONFIG_PATH=${PROJECT_DIR}/${TARGET_NAME}/Configuration/${CONFIGURATION}/${FIREBASE_CONFIG_NAME}

# Get a reference to the destination location for the GoogleService-Info.plist
PLIST_DESTINATION=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app

if [ ! -f $FIREBASE_CONFIG_PATH ]
then
    echo "error: Firebase config does not exist: $FIREBASE_CONFIG_PATH"
    exit 1
else
    echo "Using firebase config: $FIREBASE_CONFIG_PATH"
    cp "${FIREBASE_CONFIG_PATH}" "${PLIST_DESTINATION}"
fi
