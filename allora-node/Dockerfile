FROM tensorflow/tensorflow:latest-gpu

WORKDIR /app

# Cài đặt các công cụ phát triển cần thiết để biên dịch các thư viện Python, bao gồm cả python3-venv
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libc-dev \
    libssl-dev \
    python3-dev \
    python3-venv \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Tạo một môi trường ảo và cài đặt các gói Python bên trong
RUN python3 -m venv /env
ENV PATH="/env/bin:$PATH"

# Cài đặt Flask và các gói phụ thuộc từ các tệp yêu cầu
COPY requirements.txt updater-requirements.txt /app/
RUN /env/bin/pip install --upgrade pip setuptools \
    && /env/bin/pip install --timeout=360 --no-cache-dir -r /app/requirements.txt \
    && /env/bin/pip install --timeout=360 --no-cache-dir -r /app/updater-requirements.txt

# Xóa thủ công blinker sau khi cài đặt
RUN find / -name "blinker*" -exec rm -rf {} +

# Sao chép mã nguồn ứng dụng
COPY . /app

# Đảm bảo TensorFlow có thể sử dụng GPU
ENV TF_FORCE_GPU_ALLOW_GROWTH=true

# Khởi động ứng dụng
CMD ["/env/bin/gunicorn", "--conf", "/app/gunicorn_conf.py", "app:app"]
