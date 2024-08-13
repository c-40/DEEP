# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install build dependencies for dlib and additional dependencies for OpenCV
RUN apt-get update && \
    apt-get install -y cmake build-essential libgl1-mesa-glx libglib2.0-0 && \
    apt-get clean

# Copy the current directory contents into the container at /app
COPY . /app

# Copy the dlib source folder into the container
COPY dlib-19.22.1 /tmp/dlib-19.22.1

# Navigate to the dlib source folder and install it
RUN cd /tmp/dlib-19.22.1 && python setup.py install

# Copy the torch wheel file and install it
COPY wheels/torch-1.9.0-cp39-cp39-manylinux1_x86_64.whl /tmp/
RUN pip install /tmp/torch-1.9.0-cp39-cp39-manylinux1_x86_64.whl

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt --index-url https://pypi.org/simple

# Copy the model folder containing df_model.pt into the container
COPY model /app/model

# Copy the Uploaded_Files folder into the container
COPY Uploaded_Files /app/Uploaded_Files

# Ensure the templates and static folders are present
COPY templates /app/templates
COPY static /app/static

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable
ENV FLASK_APP=server.py

# Run the application
CMD ["flask", "run", "--host=0.0.0.0"]
