#!/bin/bash

# Basic script to package a Lambda function from a 'src' directory.

# Usage: ./package_lambda.sh <function_directory_name> <output_zip_file_name>
# Example: ./package_lambda.sh my_s3_processor my_s3_processor.zip

# This script assumes your Lambda source code is in:
# modules/lambda-functions/src/<function_directory_name>/

# And the output .zip file will be placed in the current directory
# or a specified output path.

LAMBDA_MODULE_BASE_PATH="./modules/lambda-functions/src"

if [ -z "$1" ]; then
  echo "Usage: $0 <function_directory_name> [output_zip_file_name]"
  echo "Example: $0 example_lambda_function example_lambda_function_payload.zip"
  exit 1
fi

FUNCTION_DIR_NAME=$1
SOURCE_PATH="${LAMBDA_MODULE_BASE_PATH}/${FUNCTION_DIR_NAME}"

# Default output zip name if not provided
OUTPUT_ZIP_NAME="${2:-${FUNCTION_DIR_NAME}_payload.zip}"
# Output directory for packaged zips (can be relative to project root)
# Ensure this directory exists or is created by your build process
# For this project structure, Terraform's archive_file uses .lambda_package_builds at the root.
# This script is more for manual packaging or if you prefer a different build step.
OUTPUT_DIR="./build/lambda_packages" 
mkdir -p "$OUTPUT_DIR"
FULL_OUTPUT_PATH="${OUTPUT_DIR}/${OUTPUT_ZIP_NAME}"


if [ ! -d "$SOURCE_PATH" ]; then
  echo "Error: Source directory '$SOURCE_PATH' not found."
  exit 1
fi

echo "Packaging Lambda function from: $SOURCE_PATH"
echo "Outputting to: $FULL_OUTPUT_PATH"

# Navigate to the source directory to include files correctly in the zip
cd "$SOURCE_PATH" || exit

# Install dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
  echo "Found requirements.txt. Installing dependencies to a temporary 'package' directory..."
  # Create a temporary package directory
  if [ -d "package" ]; then
    echo "Cleaning up existing 'package' directory..."
    rm -rf package
  fi
  mkdir package

  # Install dependencies into the 'package' directory
  # Using --system-site-packages can sometimes cause issues if the build env is different from lambda
  # pip install --system-site-packages -r requirements.txt -t ./package/ # Alternative
  pip install -r requirements.txt -t ./package/
  if [ $? -ne 0 ]; then
    echo "Error installing dependencies from requirements.txt."
    cd - > /dev/null # Go back to original directory
    exit 1
  fi
  echo "Dependencies installed."

  # Zip the contents of the package directory first
  echo "Zipping dependencies from 'package' directory..."
  zip -r9 "$FULL_OUTPUT_PATH" ./package/*
  if [ $? -ne 0 ]; then
    echo "Error zipping dependencies."
    cd - > /dev/null
    exit 1
  fi

  # Add the function code to the same zip file
  echo "Adding function code to the zip file..."
  # Exclude the package directory itself and requirements.txt from being added again at the root of the zip
  zip -g -r9 "$FULL_OUTPUT_PATH" ./* -x "./package/*" "requirements.txt"
  if [ $? -ne 0 ]; then
    echo "Error zipping function code."
    cd - > /dev/null
    exit 1
  fi

  # Clean up the temporary package directory
  echo "Cleaning up 'package' directory..."
  rm -rf package
else
  # No requirements.txt, just zip the source files
  echo "No requirements.txt found. Zipping source files directly..."
  zip -r9 "$FULL_OUTPUT_PATH" ./*
  if [ $? -ne 0 ]; then
    echo "Error zipping source files."
    cd - > /dev/null
    exit 1
  fi
fi

# Navigate back to the original directory
cd - > /dev/null

echo "Lambda function packaged successfully: $FULL_OUTPUT_PATH"
echo "Size: $(du -sh "$FULL_OUTPUT_PATH" | cut -f1)"