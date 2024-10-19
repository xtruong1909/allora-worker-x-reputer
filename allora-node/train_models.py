import os
import numpy as np
import sqlite3
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from sklearn.preprocessing import MinMaxScaler
import joblib
from app_config import DATABASE_PATH

# Đảm bảo thư mục models tồn tại
os.makedirs('models', exist_ok=True)

# Hàm tải dữ liệu từ cơ sở dữ liệu SQLite
def load_data(token_name):
    try:
        with sqlite3.connect(DATABASE_PATH) as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT price FROM prices 
                WHERE token=?
                ORDER BY block_height ASC
            """, (token_name,))
            result = cursor.fetchall()
        return np.array([x[0] for x in result]).reshape(-1, 1)
    except sqlite3.Error as e:
        print(f"Failed to load data for {token_name}: {str(e)}")
        return np.array([]).reshape(-1, 1)

# Chuẩn bị dữ liệu cho LSTM
def prepare_data_for_lstm(data, look_back, prediction_horizon):
    if data.shape[0] == 0:
        raise ValueError("No data available for training.")
    
    scaler = MinMaxScaler(feature_range=(0, 1))
    scaled_data = scaler.fit_transform(data)

    X, Y = [], []
    for i in range(len(scaled_data) - look_back - prediction_horizon):
        X.append(scaled_data[i:(i + look_back), 0])
        Y.append(scaled_data[i + look_back + prediction_horizon - 1, 0])

    X = np.array(X).reshape((len(X), look_back, 1))
    Y = np.array(Y)
    return X, Y, scaler

# Tạo mô hình LSTM
def create_lstm_model(look_back):
    model = Sequential()
    model.add(LSTM(100, return_sequences=True, input_shape=(look_back, 1)))
    model.add(Dropout(0.2))  # Dropout để giảm overfitting
    model.add(LSTM(100))
    model.add(Dense(50, activation='relu'))  # Lớp Dense bổ sung
    model.add(Dense(1))
    model.compile(optimizer='adam', loss='mean_squared_error')
    return model

# Huấn luyện và lưu mô hình cùng với scaler
def train_and_save_model(token_name, look_back, prediction_horizon):
    try:
        print(f"Training model for {token_name} with a {prediction_horizon}-minute horizon.")
        
        # Tải và chuẩn bị dữ liệu
        data = load_data(token_name)
        if data.shape[0] == 0:
            print(f"No data available for {token_name}, skipping training.")
            return

        X, Y, scaler = prepare_data_for_lstm(data, look_back, prediction_horizon)

        # Tạo và huấn luyện mô hình
        model = create_lstm_model(look_back)
        model.fit(X, Y, epochs=10, batch_size=1, verbose=2)

        # Lưu mô hình dưới định dạng Keras
        model_path = f'models/{token_name.lower()}_model_{prediction_horizon}m.keras'
        model.save(model_path, save_format='keras')

        # Lưu scaler dưới định dạng .pkl
        scaler_path = f'models/{token_name.lower()}_scaler_{prediction_horizon}m.pkl'
        joblib.dump(scaler, scaler_path)

        print(f"Model and scaler for {token_name} ({prediction_horizon}-minute prediction) saved to {model_path} and {scaler_path}.")
    
    except Exception as e:
        print(f"Error occurred while training model for {token_name}: {str(e)}")

# Định nghĩa các khoảng thời gian dự đoán
time_horizons = {
    '10m': (10, 10),       # LOOK_BACK=10, PREDICTION_HORIZON=10
    '20m': (10, 20),       # LOOK_BACK=10, PREDICTION_HORIZON=20
    '24h': (1440, 1440)    # LOOK_BACK=1440, PREDICTION_HORIZON=1440
}

# Huấn luyện cho từng token với các khoảng thời gian khác nhau
tokens = ['ETH', 'ARB', 'BTC', 'SOL', 'BNB']

for token in tokens:
    for horizon_name, (look_back, prediction_horizon) in time_horizons.items():
        train_and_save_model(f"{token}USD", look_back, prediction_horizon)
