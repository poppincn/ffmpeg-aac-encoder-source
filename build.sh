#!/usr/bin/env bash
# 复现 @mediabunny/aac-encoder 1.65.2 里的 build/aac.js（FFmpeg 的 AAC 编码器编成 WebAssembly）。
# Reproduces build/aac.js of @mediabunny/aac-encoder 1.65.2 (FFmpeg's AAC encoder compiled to WebAssembly).
#
# 需要 / Requires: Emscripten 4.0.21 (emsdk), with `source emsdk_env.sh` done.
# 用法 / Usage: ./build.sh /path/to/FFmpeg-60a2818f76dcd1fee3155b1791304af104a0fc1b
set -euo pipefail

FFMPEG_PATH=$(cd "${1:?FFmpeg source directory}" && pwd)
HERE=$(cd "$(dirname "$0")" && pwd)

cd "$FFMPEG_PATH"
emmake make distclean || true
emconfigure ./configure \
    --target-os=none \
    --arch=x86_32 \
    --enable-cross-compile \
    --disable-asm \
    --disable-x86asm \
    --disable-inline-asm \
    --disable-programs \
    --disable-doc \
    --disable-debug \
    --disable-all \
    --disable-everything \
    --disable-autodetect \
    --disable-pthreads \
    --disable-runtime-cpudetect \
    --enable-avcodec \
    --enable-encoder=aac \
    --cc="emcc" \
    --cxx=em++ \
    --ar=emar \
    --ranlib=emranlib \
    --extra-cflags="-DNDEBUG -Oz -flto -msimd128" \
    --extra-ldflags="-Oz -flto"
emmake make

mkdir -p "$HERE/build"
cd "$HERE"
emcc src/bridge.c \
    "$FFMPEG_PATH/libavcodec/libavcodec.a" \
    "$FFMPEG_PATH/libavutil/libavutil.a" \
    -I"$FFMPEG_PATH" \
    -s MODULARIZE=1 \
    -s EXPORT_ES6=1 \
    -s SINGLE_FILE=1 \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s ENVIRONMENT=web,worker \
    -s FILESYSTEM=0 \
    -s MALLOC=emmalloc \
    -s SUPPORT_LONGJMP=0 \
    -s EXPORTED_RUNTIME_METHODS=cwrap,HEAPU8 \
    -s EXPORTED_FUNCTIONS=_malloc,_free \
    -msimd128 \
    -flto \
    -Oz \
    -o build/aac.js

echo "built: $HERE/build/aac.js"
