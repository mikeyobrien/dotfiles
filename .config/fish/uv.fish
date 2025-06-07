# UV/uvx configuration
# Only loaded if uv is available

# Use a custom cache directory and enable symlinks for better performance
set -gx UV_CACHE_DIR "$HOME/uv-cache"
set -gx UV_LINK_MODE symlink