#!/bin/sh
set -e

# 设置默认值
SUBCONVERTER_BACKEND=${VUE_APP_SUBCONVERTER_DEFAULT_BACKEND:-https://url.v1.mk}
MYURLS_BACKEND=${VUE_APP_MYURLS_DEFAULT_BACKEND:-https://v1.mk}
CONFIG_UPLOAD_BACKEND=${VUE_APP_CONFIG_UPLOAD_BACKEND:-https://subapi.v1.mk}

# 生成前端配置文件
cat > /usr/share/nginx/html/config.js <<EOF
window.APP_CONFIG = {
  SUBCONVERTER_BACKEND: '${SUBCONVERTER_BACKEND}',
  MYURLS_BACKEND: '${MYURLS_BACKEND}',
  CONFIG_UPLOAD_BACKEND: '${CONFIG_UPLOAD_BACKEND}'
}
EOF

echo "Configuration generated:"
cat /usr/share/nginx/html/config.js

# 启动 nginx
exec nginx -g 'daemon off;'
