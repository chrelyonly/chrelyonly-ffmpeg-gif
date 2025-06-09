#!/bin/bash
set -e

export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig
PREFIX_DIR="$PWD/build-linux"

echo "📥 进入 FFmpeg 源码目录..."
cd /ffmpeg

# 清除残留配置（尤其是 mingw 上次留下的）
echo "🧹 执行 distclean 清理旧配置..."
make distclean || true

echo "⚙️ 配置编译参数 (Linux 静态版)..."
./configure \
  --prefix="$PREFIX_DIR" \
  --enable-gpl \
  --enable-version3 \
  --enable-libwebp \
  --enable-libfreetype \
  --enable-pic \
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

echo "✅ Linux 编译完成: $PREFIX_DIR/bin/ffmpeg"
"$PREFIX_DIR/bin/ffmpeg" -version
