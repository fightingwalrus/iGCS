# Copy all files that have been downloaded into the dependencies 
# directory to the root of the app bundle. The script will not
# error and break the build if the dependencies dir does not 
# exist so that those without access to some of the internal 
# dependecies are still able to build the project.

DEPS_DIR=${SRCROOT}/dependencies/
if [ -d "$DEPS_DIR" ]; then
  cp -R $DEPS_DIR \
  ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/
fi
