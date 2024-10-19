# Sử dụng TensorFlow GPU với phiên bản CUDA và cuDNN đã tích hợp
FROM tensorflow/tensorflow:latest-gpu

# Thiết lập thư mục làm việc bên trong container
WORKDIR /app

# Cài đặt các phụ thuộc hệ thống
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    build-essential \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Sao chép requirements.txt vào container
COPY requirements.txt .

# Sao chép mã nguồn ứng dụng
COPY train_models.py app_config.py .

# Đảm bảo TensorFlow có thể sử dụng GPU
ENV TF_FORCE_GPU_ALLOW_GROWTH=true

# Khởi chạy script đào tạo
CMD ["python3", "train_models.py"]
