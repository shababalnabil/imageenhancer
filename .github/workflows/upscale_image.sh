#!/bin/bash

# Check for an image file in the current directory
INPUT_IMAGE=""
OUTPUT_IMAGE="output_image.png"

# Check for .jpg or .png files
if [[ -f "image.jpg" ]]; then
    INPUT_IMAGE="image.jpg"
elif [[ -f "image.png" ]]; then
    INPUT_IMAGE="image.png"
else
    echo "No image found in the current directory. Please place image.jpg or image.png."
    exit 1
fi

# Check if the model is already downloaded
MODEL_DIR="models"
MODEL_FILE="$MODEL_DIR/esrgan_fp16.tflite"
if [ ! -f "$MODEL_FILE" ]; then
    echo "Model not found. Downloading the ESRGAN model..."
    mkdir -p $MODEL_DIR
    wget -O "$MODEL_FILE" https://github.com/margaretmz/esrgan-e2e-tflite-tutorial/releases/download/v0.1.0/esrgan_fp16.tar.gz
    tar -xvzf "$MODEL_FILE" -C $MODEL_DIR
    echo "Model downloaded and extracted."
else
    echo "Model already exists."
fi

# Run the image enhancement process using Docker
echo "Running ESRGAN on $INPUT_IMAGE..."

docker run --rm \
    -v "$(pwd)":/workspace \
    -w /workspace \
    tensorflow/tensorflow:2.7.0-py3 \
    bash -c "
    python3 -m pip install --no-cache-dir -r requirements.txt &&
    python3 esrgan_inference.py --input $INPUT_IMAGE --output $OUTPUT_IMAGE
"

echo "Image upscaled! Output saved as $OUTPUT_IMAGE"

# If running in GitHub Actions, you can upload the image or just output the result
# For GitHub Actions, you might want to save the output and use a step to upload it
