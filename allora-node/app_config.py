import os

# Đường dẫn cơ sở cho ứng dụng
APP_BASE_PATH = os.getenv("APP_BASE_PATH", default=os.getcwd())

# Đường dẫn thư mục chứa dữ liệu
DATA_BASE_PATH = os.path.join(APP_BASE_PATH, "data")

# Đường dẫn cơ sở dữ liệu, ưu tiên lấy từ biến môi trường nếu có
DATABASE_PATH = os.getenv('DATABASE_PATH', os.path.join(DATA_BASE_PATH, 'prices.db'))

# Loại worker (dùng biến môi trường hoặc mặc định là 1)
WORKER_TYPE = int(os.getenv('WORKER_TYPE', 1))

# Thời gian giữa các block (giây)
BLOCK_TIME_SECONDS = int(os.getenv('BLOCK_TIME_SECONDS', 5))

# URL API của Allora Validator
ALLORA_VALIDATOR_API_URL = os.getenv('ALLORA_VALIDATOR_API_URL', 'http://localhost:1317/')

# Endpoint để truy vấn block mới nhất
URL_QUERY_LATEST_BLOCK = "cosmos/base/tendermint/v1beta1/blocks/latest"

# API key của CoinGecko (CGC)
CGC_API_KEY = os.getenv('CGC_API_KEY', '')

# In ra thông tin cấu hình để kiểm tra
print(f"App Base Path: {APP_BASE_PATH}")
print(f"Database Path: {DATABASE_PATH}")
print(f"Worker Type: {WORKER_TYPE}")
print(f"Allora Validator API URL: {ALLORA_VALIDATOR_API_URL}")
