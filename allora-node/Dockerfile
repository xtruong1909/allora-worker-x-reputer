FROM tensorflow/tensorflow:latest-gpu

WORKDIR /app

# Cài đặt các công cụ phát triển cần thiết để biên dịch các thư viện Python
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libc-dev \
    libssl-dev \
    python3-dev \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3

# Cài đặt các gói phụ thuộc trực tiếp
RUN pip install --upgrade pip setuptools \
    && pip install --timeout=360 --no-cache-dir numpy==1.24.3 flask[async] gunicorn[gthread] retrying==1.3.3 requests pandas==2.1.3 torch scikit-learn==1.3.0 aiohttp==3.8.1 joblib==1.3.2

# Sao chép mã nguồn ứng dụng
COPY . /app

# Tạo script để xóa blinker trong container khi chạy
RUN echo "#!/bin/bash\nfind / -name \"blinker*\" 2>/dev/null | xargs rm -rf" > /app/remove_blinker.sh \
    && chmod +x /app/remove_blinker.sh

# Đảm bảo TensorFlow có thể sử dụng GPU
ENV TF_FORCE_GPU_ALLOW_GROWTH=true

# Khởi động ứng dụng
CMD ["/bin/bash", "-c", "/app/remove_blinker.sh && gunicorn --conf /app/gunicorn_conf.py app:app"]
