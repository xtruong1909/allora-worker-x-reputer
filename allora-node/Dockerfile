FROM tensorflow/tensorflow:latest-gpu

WORKDIR /app

# Cài đặt các công cụ phát triển cần thiết để biên dịch các thư viện Python, bao gồm cả python3-venv
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

# Sao chép file yêu cầu và cài đặt các gói
COPY requirements.txt updater-requirements.txt /app/

# Cài đặt Flask và các gói từ requirements
RUN pip install --upgrade pip setuptools \
    && pip install --timeout=360 --no-cache-dir -r /app/requirements.txt \
    && pip install --timeout=360 --no-cache-dir -r /app/updater-requirements.txt \
    && pip install Flask==2.1.2

# Sao chép mã nguồn ứng dụng
COPY . /app

# Tạo script để xóa blinker trong container khi chạy
RUN echo "#!/bin/bash\nfind / -name \"blinker*\" 2>/dev/null | xargs rm -rf" > /app/remove_blinker.sh \
    && chmod +x /app/remove_blinker.sh

# Đảm bảo TensorFlow có thể sử dụng GPU
ENV TF_FORCE_GPU_ALLOW_GROWTH=true

# Khởi động ứng dụng
CMD ["/bin/bash", "-c", "/app/remove_blinker.sh && gunicorn --conf /app/gunicorn_conf.py app:app"]
