# Copy all files in the private firmwarebins submodule directory
# to the root of the app bundle. The copy will continue if there
# are files that don't exist so it won't hinder development by
# those without access to the firmwarebins submodule.

FIRMWARE_BINS_DIR=${SRCROOT}/submodules/firmwarebins/
if [ -d "$FIRMWARE_BINS_DIR" ]; then
  cp -R $FIRMWARE_BINS_DIR \
  ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/
fi