#!/bin/bash

set -e

FFMPEG_BINARY="./ffmpeg"

if [[ ! -f "$FFMPEG_BINARY" ]]; then
  echo "❌ 未找到 ffmpeg 可执行文件: $FFMPEG_BINARY"
  exit 1
fi

echo "🔍 正在检查 FFmpeg 缺失依赖库..."

# 检查是否为动态可执行文件
if ldd "$FFMPEG_BINARY" 2>&1 | grep -q "not a dynamic executable"; then
  echo "✅ 该 ffmpeg 是静态构建版本，无需安装依赖。"
  exit 0
fi

# 获取缺失的库名
missing_libs=$(ldd "$FFMPEG_BINARY" | grep "not found" | awk '{print $1}')

if [[ -z "$missing_libs" ]]; then
  echo "✅ 所有依赖已满足，无需安装。"
  exit 0
fi

echo "❗ 检测到以下缺失的库："
echo "$missing_libs"
echo ""

# 库名与 apt 包名映射表（可扩展）
declare -A lib_map=(
  ["libxcb-shm.so.0"]="libxcb-shm0"
  ["libxcb-shape.so.0"]="libxcb-shape0"
  ["libxcb-xfixes.so.0"]="libxcb-xfixes0"
  ["libxcb.so.1"]="libxcb1"
  ["libx11.so.6"]="libx11-6"
  ["libxext.so.6"]="libxext6"
  ["libdrm.so.2"]="libdrm2"
  ["libva.so.2"]="libva2"
  ["libva-drm.so.2"]="libva-drm2"
  ["libXv.so.1"]="libxv1"
  ["libasound.so.2"]="libasound2"
  ["libz.so.1"]="zlib1g"
  ["libvdpau.so.1"]="libvdpau1"
)

install_list=()

for lib in $missing_libs; do
  pkg="${lib_map[$lib]}"
  if [[ -n "$pkg" ]]; then
    install_list+=("$pkg")
  else
    echo "⚠️ 无法自动匹配 apt 包名: $lib，请手动安装对应依赖。"
  fi
done

if [[ ${#install_list[@]} -eq 0 ]]; then
  echo "🚫 无法自动安装任何依赖，请手动处理。"
  exit 1
fi

echo "📦 正在安装缺失依赖: ${install_list[*]}"
sudo apt update
sudo apt install -y "${install_list[@]}"

echo ""
echo "✅ 所有检测到的依赖已安装完成。"
