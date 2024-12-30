FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
  poppler-utils \
  tesseract-ocr \
  pandoc \
  parallel \
  && apt-get clean

# Set the working directory
WORKDIR /app

# Copy the script into the container
COPY scripts.sh /app/scripts.sh

# Make the script executable
RUN chmod +x /app/scripts.sh

# Define the default command
# CMD ["/app/scripts.sh"]
