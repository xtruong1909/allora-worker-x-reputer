import os
from app_utils import init_price_token
import sys

def initialize_tokens():
    """
    Hàm khởi tạo dữ liệu cho các token được chỉ định trong biến môi trường `TOKENS`.
    Cấu trúc: 'ETH:ETHUSD,BTC:BTCUSD'
    """
    try:
        tokens = os.getenv('TOKENS', '').split(',')
        if not tokens or len(tokens) == 0:
            print("No tokens specified in the TOKENS environment variable.")
            sys.exit(1)

        print(f"Tokens to initialize: {tokens}")

        for token in tokens:
            token_parts = token.split(':')
            if len(token_parts) != 2:
                print(f"Invalid token format: {token}. Expected format is <symbol>:<token_name>.")
                continue

            symbol, token_name = token_parts[0], token_parts[1]
            print(f"Initializing data for {token_name} token.")
            init_price_token(symbol, token_name, 'usd')

    except Exception as e:
        print(f"Failed to initialize tokens: {str(e)}")
        sys.exit(1)
    else:
        print("Tokens initialized successfully.")
    finally:
        sys.exit(0)

if __name__ == "__main__":
    initialize_tokens()
