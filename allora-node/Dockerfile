FROM tensorflow/tensorflow:latest-gpu

WORKDIR /app

# Xóa thủ công blinker nếu nó đã được cài đặt trước đó
RUN rm -rf /usr/lib/python3/dist-packages/blinker-1.4.egg-info /usr/lib/python3/dist-packages/blinker*

COPY requirements.txt updater-requirements.txt /app/

# Cài đặt các gói từ requirements.txt
RUN pip install --upgrade pip setuptools \
    && pip install --timeout=360 --no-cache-dir --ignore-installed -r /app/updater-requirements.txt

COPY gunicorn_conf.py app.py app_config.py app_utils.py init_data.py /app/

ENV TF_FORCE_GPU_ALLOW_GROWTH=true

CMD ["gunicorn", "--conf", "/app/gunicorn_conf.py", "app:app"]
