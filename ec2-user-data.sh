#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on

# Create app directory
mkdir /home/ec2-user/app
cd /home/ec2-user/app

# Create app.py
cat <<EOF > app.py
from flask import Flask, jsonify
import random

app = Flask(__name__)

words = ["Investments", "Smallcase", "Stocks", "buy-the-dip", "TickerTape"]

@app.route("/api/v1", methods=["GET"])
def get_random_word():
    return jsonify({"word": random.choice(words)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8081)
EOF

# Create requirements.txt
cat <<EOF > requirements.txt
flask
EOF

# Create Dockerfile
cat <<EOF > Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py app.py
CMD ["python", "app.py"]
EOF

# Build and run Docker container
docker build -t random-string-app .
docker run -d -p 8081:8081 random-string-app
