FROM tensorflow/tensorflow:latest-gpu

WORKDIR /app

# Ngừng cài đặt blinker từ Docker image ban đầu
RUN rm -rf /usr/lib/python3/dist-packages/blinker* /usr/local/lib/python3*/dist-packages/blinker*

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
    && pip install --timeout=360 --no-cache-dir numpy==1.24.3 flask[async] gunicorn[gthread] retrying==1.3.3 requests pandas==2.1.3 torch scikit-learn==1.3.0 aiohttp==3.8.1 joblib==1.3.2 || pip install pandas==2.1.3

# Xóa blinker trong container sau khi cài đặt các gói
RUN rm -rf /usr/lib/python3/dist-packages/blinker* /usr/local/lib/python3*/dist-packages/blinker*

# Cài đặt pandas vào tất cả các môi trường Python có thể
RUN for env in /usr/local/lib/python3*/dist-packages /usr/lib/python3*/dist-packages; do \
    if [ -d "$env" ]; then \
        pip install --target=$env pandas==2.1.3; \
    fi; \
  done

# Sao chép mã nguồn ứng dụng
COPY . /app

# Đảm bảo TensorFlow có thể sử dụng GPU
ENV TF_FORCE_GPU_ALLOW_GROWTH=true

# Khởi động ứng dụng
CMD ["gunicorn", "--conf", "/app/gunicorn_conf.py", "app:app"]
