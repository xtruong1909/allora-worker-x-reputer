# Sử dụng Docker image TensorFlow GPU với CUDA và cuDNN tích hợp sẵn
FROM tensorflow/tensorflow:latest-gpu

# Thiết lập thư mục làm việc bên trong container
WORKDIR /app

# Cài đặt các thư viện Python bổ sung từ requirements.txt
COPY requirements.txt .
RUN pip install --upgrade pip setuptools \
    && pip install --timeout=360 --no-cache-dir --ignore-installed -r updater-requirements.txt

# Sao chép mã nguồn ứng dụng vào container
COPY gunicorn_conf.py app.py app_config.py app_utils.py init_data.py /app/

# Đảm bảo TensorFlow có thể sử dụng GPU
ENV TF_FORCE_GPU_ALLOW_GROWTH=true

# Khởi động ứng dụng với Gunicorn
CMD ["gunicorn", "--conf", "/app/gunicorn_conf.py", "app:app"]
