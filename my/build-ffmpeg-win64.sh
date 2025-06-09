#!/bin/bash
set -e

# 输出目录
PREFIX_DIR="$PWD/build-win64"

echo "📦 安装 MinGW 工具链（如未安装）"
apt update
apt install -y mingw-w64 yasm nasm git make pkg-config autoconf automake libtool

echo "📥 清理并进入 FFmpeg 源码目录..."
cd /ffmpeg

echo "🧹 执行 distclean 清理旧配置..."
make distclean || true

echo "⚙️ 配置编译参数 (Windows 64-bit 静态版)..."
./configure \
  --prefix="$PREFIX_DIR" \
  --target-os=mingw32 \
  --arch=x86_64 \
  --cross-prefix=x86_64-w64-mingw32- \
  --cc=x86_64-w64-mingw32-gcc \
  --ld=x86_64-w64-mingw32-gcc \
  --enable-cross-compile \
  --enable-gpl \
  --enable-version3 \
  --enable-ffmpeg \
  --disable-ffplay \
  --disable-ffprobe \
  --disable-doc \
  --enable-static \
  --disable-shared \
  --disable-debug

echo "🚧 编译中..."
make -j"$(nproc)"

echo "📦 安装到: $PREFIX_DIR"
make install

echo "✅ Windows 编译完成: $PREFIX_DIR/bin/ffmpeg.exe"
"$PREFIX_DIR/bin/ffmpeg.exe" -version
