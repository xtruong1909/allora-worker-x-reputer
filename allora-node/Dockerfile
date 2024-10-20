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
    libffi-dev \
    python3-dev \
    build-essential \
    python3-pip \
    python3-wheel \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt pip
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3

# Kiểm tra phiên bản Python và Pip
RUN which python && python --version
RUN which pip && pip --version

# Cài đặt các gói phụ thuộc trực tiếp và pandas
RUN python -m pip install --upgrade pip setuptools \
    && python -m pip install --timeout=360 --no-cache-dir numpy flask[async] gunicorn[gthread] retrying==1.3.3 requests torch scikit-learn aiohttp joblib pandas

# Cài đặt scikit-learn trong tất cả các môi trường Python có sẵn
RUN for python_bin in /usr/bin/python*; do \
    if [[ "$python_bin" =~ python[0-9.]+$ ]]; then \
        "$python_bin" -m pip install --upgrade pip setuptools && "$python_bin" -m pip install scikit-learn; \
    fi; \
done

# Kiểm tra `pandas` đã cài đặt thành công
RUN python -c "import pandas; print('Pandas version:', pandas.__version__)"

# Sao chép mã nguồn ứng dụng
COPY . /app

# Đảm bảo TensorFlow có thể sử dụng GPU
ENV TF_FORCE_GPU_ALLOW_GROWTH=true

# Khởi động ứng dụng
CMD ["gunicorn", "--conf", "/app/gunicorn_conf.py", "app:app"]
