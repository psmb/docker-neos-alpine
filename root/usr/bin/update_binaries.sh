# Run this file locally on the machine when you want to update the binaries.
# We don't want to put this inside the Dockerfile not to burden the image with npm.

npm i
cp -f node_modules/.bin/optipng .
cp -f node_modules/.bin/jpegtran .
rm -rf node_modules

# svgo and gifsicle can not be copied as binaries :-(
