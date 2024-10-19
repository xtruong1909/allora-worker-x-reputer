#!/bin/bash

# SPDX-License-Identifier: AGPL-3.0

# Hướng dẫn cài đặt công cụ cần thiết:
# go install github.com/jandelgado/gcov2lcov@latest 
# brew install lcov

# Dừng ngay nếu có lỗi xảy ra trong bất kỳ lệnh nào
set -o errexit
set -o pipefail  # Đảm bảo bắt lỗi trong các pipeline

# 1) Chạy kiểm tra với báo cáo coverage
echo "Running tests and generating coverage report..."
go test ./... -coverprofile=coverage.out

# 2) Chuyển đổi từ Go coverage sang lcov
echo "Converting Go coverage to lcov format..."
gcov2lcov -infile=coverage.out -outfile=coverage_raw.lcov

# 3) Định nghĩa danh sách các mẫu cần loại trừ
exclude_patterns=(
    'x/emissions/types/*.pb.go'
    'x/emissions/types/*.pb.gw.go'
    'math/collections.go'
)

# 4) Loại trừ các tệp không cần thiết khỏi báo cáo coverage
echo "Excluding unwanted files from coverage report..."
for pattern in "${exclude_patterns[@]}"; do
    lcov --remove coverage_raw.lcov "$pattern" -o coverage_temp.lcov
    mv coverage_temp.lcov coverage_raw.lcov
done

# 5) Xóa tệp coverage ban đầu và chuẩn bị thư mục mới
rm -f coverage.out
mkdir -p coverage

# 6) Tạo báo cáo coverage dưới dạng HTML
echo "Generating HTML coverage report..."
genhtml coverage_raw.lcov --dark-mode -o coverage

# 7) Dọn dẹp các tệp không cần thiết
rm -f coverage_raw.lcov
mv coverage/coverage_raw.lcov coverage/coverage.lcov

echo "Success! Coverage data is viewable at coverage/index.html"
