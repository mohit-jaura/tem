#/bin/sh

CONFIG_NAME=env.json

DEFAULT_CONFIG_PATH=${PROJECT_DIR}/TemApp/Configuration/$CONFIG_NAME
ENV_CONFIG_PATH=${PROJECT_DIR}/TemApp/Configuration/${CONFIGURATION}/$CONFIG_NAME
DESTINATION=${BUILT_PRODUCTS_DIR}/${FULL_PRODUCT_NAME}

if [ ! -f $DEFAULT_CONFIG_PATH ]
then
    echo "error: Default config does not exist: $DEFAULT_CONFIG_PATH"
    exit 1
else
    echo "Copying default configuration from $DEFAULT_CONFIG_PATH to $DESTINATION"
    cp "$DEFAULT_CONFIG_PATH" "$DESTINATION"
fi

if [ ! -f $ENV_CONFIG_PATH ]
then
    echo "warning: Configuration merging skipped as env config does not exist: $ENV_CONFIG_PATH"
else
    echo "Merging configuration from $ENV_CONFIG_PATH to $DESTINATION/$CONFIG_NAME"
    node ${PROJECT_DIR}/scripts/merge-config.js "$DESTINATION/$CONFIG_NAME" "$ENV_CONFIG_PATH"
fi
