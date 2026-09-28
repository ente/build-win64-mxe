#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  x86_64|aarch64) arch=$1 ;;
  *) echo "Usage: $0 {x86_64|aarch64}" >&2; exit 1 ;;
esac
cd "$(dirname "$0")"

target="$arch-w64-mingw32.static"
image="vips-cli-windows-$arch"
base_image="ghcr.io/libvips/build-win64-mxe@sha256:306f986a3e9daea18a03f30694a9843524e2ccdf90a0b5833cb51120186375bd"
plugins="plugins/llvm-mingw /data /data/plugins/mozjpeg /data/plugins/zlib-ng /data/plugins/proxy-libintl /data/plugins/web-deps /data/plugins/hevc-deps /data/plugins/cli"

docker build --platform=linux/amd64 -t "$image" -f container/Dockerfile \
  --build-arg BASE_IMAGE="$base_image" \
  --build-arg SOURCE_DATE_EPOCH="$(git log -1 --pretty=%ct)" \
  --build-arg PKGS=vips \
  --build-arg MXE_TARGETS="$target" \
  --build-arg DEBUG=false \
  --build-arg PLUGIN_DIRS="$plugins" \
  build

mkdir -p output
docker run --rm --platform=linux/amd64 --entrypoint /bin/bash \
  -v "$PWD/output:/output" "$image" -euc '
    target="$1"
    arch="${target%%-*}"
    prefix="/usr/local/mxe/usr/$target"
    install -m 755 "$prefix/bin/vips.exe" "/output/vips-$arch.exe"
  ' bash "$target"
