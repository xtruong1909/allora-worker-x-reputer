import os
import sys
import sqlite3
from app_config import DATABASE_PATH, CGC_API_KEY
from app_utils import get_latest_network_block, check_create_table
from concurrent.futures import ThreadPoolExecutor
import retrying
import requests

# Hàm lấy dữ liệu từ API với retry
@retrying.retry(
    wait_exponential_multiplier=1000, 
    wait_exponential_max=10000, 
    stop_max_attempt_number=5
)
def fetch_cg_data(url):
    headers = {
        "accept": "application/json",
        "x-cg-demo-api-key": CGC_API_KEY
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

# Hàm cập nhật giá token vào cơ sở dữ liệu
def update_price(token_name, token_from, token_to='usd'):
    try:
        # Kiểm tra và tạo bảng nếu chưa tồn tại
        check_create_table()

        # Lấy giá từ CoinGecko API
        url = f'https://api.coingecko.com/api/v3/simple/price?ids={token_from}&vs_currencies={token_to}'
        prices = fetch_cg_data(url)

        if token_from.lower() not in prices:
            print(f"Invalid token ID: {token_from}")
            return

        price = prices[token_from.lower()][token_to.lower()]

        # Lấy block height mới nhất từ mạng Allora
        block_data = get_latest_network_block()
        latest_block_height = block_data['block']['header'].get('height', 0)

        if latest_block_height == 0:
            print(f"Failed to fetch latest block height.")
            return

        # Ghi dữ liệu vào cơ sở dữ liệu SQLite
        token = token_name.lower()
        with sqlite3.connect(DATABASE_PATH) as conn:
            cursor = conn.cursor()
            cursor.execute(
                "INSERT OR REPLACE INTO prices (block_height, token, price) VALUES (?, ?, ?)",
                (latest_block_height, token, price)
            )
            conn.commit()

        print(f"Inserted data point {latest_block_height} : {price}")

    except requests.RequestException as e:
        print(f"API request error for {token_name}: {str(e)}")
    except sqlite3.Error as e:
        print(f"Database error: {str(e)}")
    except Exception as e:
        print(f"Unexpected error occurred while updating {token_name}: {str(e)}")

# Hàm chính để cập nhật giá cho nhiều token
def main():
    try:
        # Lấy danh sách token từ biến môi trường TOKENS
        tokens = os.getenv('TOKENS', '').split(',')
        if not tokens or tokens == ['']:
            print("No tokens specified in TOKENS environment variable.")
            sys.exit(1)

        print(f"Updating prices for tokens: {tokens}")

        # Sử dụng ThreadPoolExecutor để chạy cập nhật đồng thời
        with ThreadPoolExecutor() as executor:
            executor.map(
                lambda token: update_price(f"{token.split(':')[0]}USD", token.split(':')[1], 'usd'), 
                tokens
            )

    except KeyError as e:
        print(f"Environment variable {str(e)} not found.")
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
    finally:
        sys.exit(0)

# Chạy hàm main nếu script được chạy trực tiếp
if __name__ == "__main__":
    main()
