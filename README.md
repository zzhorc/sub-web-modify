# Sub-Web-Modify (自用修改版)

> 基于 [youshandefeiyang/sub-web-modify](https://github.com/youshandefeiyang/sub-web-modify) 修改  
> 原项目基于 [CareyWang/sub-web](https://github.com/CareyWang/sub-web)

## ✨ 主要修改

相比原项目，本版本做了以下改进：

1. **✅ 支持运行时环境变量配置**
   - 可通过 Docker 环境变量动态配置后端转换地址
   - 可通过 Docker 环境变量动态配置短链接服务地址
   - 自定义配置会自动添加到下拉列表并默认选中

2. **✅ 去除广告弹窗**
   - 移除了原项目的 TG 交流群等广告弹窗
   - 提供更清爽的使用体验

3. **✅ 修复后端版本 API**
   - 修复了后端版本检查 API 使用硬编码地址的问题
   - 现在会自动使用自定义后端地址获取版本信息

## 🐳 Docker 镜像

Docker Hub: [`zzhorc/sub-web-modify`](https://hub.docker.com/r/zzhorc/sub-web-modify)

支持架构：
- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64/aarch64)

## 📦 使用方法

### 方法一：Docker Run

#### 使用默认配置

```bash
docker run -d --restart always \
  -p 8090:80 \
  --name sub-web-modify \
  zzhorc/sub-web-modify:latest
```

#### 使用自定义后端（推荐）

```bash
docker run -d --restart always \
  -p 8090:80 \
  -e VUE_APP_SUBCONVERTER_DEFAULT_BACKEND=https://your-backend.com \
  -e VUE_APP_MYURLS_DEFAULT_BACKEND=https://your-shorturl.com \
  --name sub-web-modify \
  zzhorc/sub-web-modify:latest
```

### 方法二：Docker Compose

创建 `docker-compose.yaml` 文件：

```yaml
services:
  sub-web-modify:
    image: zzhorc/sub-web-modify:latest
    container_name: sub-web-modify
    restart: always
    ports:
      - "8090:80"
    environment:
      # 订阅转换后端地址
      - VUE_APP_SUBCONVERTER_DEFAULT_BACKEND=https://your-backend.com
      # 短链接服务地址
      - VUE_APP_MYURLS_DEFAULT_BACKEND=https://your-shorturl.com
      # 配置上传后端地址（可选）
      # - VUE_APP_CONFIG_UPLOAD_BACKEND=https://your-config-api.com
```

启动服务：

```bash
docker compose up -d
```

更新镜像：

```bash
docker compose pull
docker compose up -d
```

## ⚙️ 环境变量说明

| 环境变量 | 说明 | 默认值 | 是否必需 |
|---------|------|--------|---------|
| `VUE_APP_SUBCONVERTER_DEFAULT_BACKEND` | 订阅转换后端地址 | `https://url.v1.mk` | 否 |
| `VUE_APP_MYURLS_DEFAULT_BACKEND` | 短链接服务地址 | `https://v1.mk` | 否 |
| `VUE_APP_CONFIG_UPLOAD_BACKEND` | 配置上传后端地址 | `https://subapi.v1.mk` | 否 |

### 配置示例

假设您有自己的后端服务：
- 订阅转换后端：`https://subc.example.com`
- 短链接服务：`https://s.example.com`

Docker Run 方式：

```bash
docker run -d --restart always \
  -p 8090:80 \
  -e VUE_APP_SUBCONVERTER_DEFAULT_BACKEND=https://subc.example.com \
  -e VUE_APP_MYURLS_DEFAULT_BACKEND=https://s.example.com \
  --name sub-web-modify \
  zzhorc/sub-web-modify:latest
```

Docker Compose 方式：

```yaml
services:
  sub-web-modify:
    image: zzhorc/sub-web-modify:latest
    container_name: sub-web-modify
    restart: always
    ports:
      - "8090:80"
    environment:
      - VUE_APP_SUBCONVERTER_DEFAULT_BACKEND=https://subc.example.com
      - VUE_APP_MYURLS_DEFAULT_BACKEND=https://s.example.com
```

## 🌐 访问

启动后访问：`http://your-server-ip:8090`

## 📝 注意事项

1. **短链接服务 CORS 配置**：如果使用自定义短链接服务，需要在短链接服务的 Nginx 配置中添加 CORS 头，详见 [CORS 配置说明](#-cors-配置短链接服务)

2. **端口冲突**：如果 8090 端口被占用，可以修改端口映射，例如 `-p 58080:80`

3. **架构兼容性**：镜像支持 AMD64 和 ARM64 架构，Docker 会自动选择对应架构的镜像

## 🔧 CORS 配置（短链接服务）

如果您使用自定义短链接服务，需要在短链接服务的 Nginx 配置中添加 CORS 头，否则浏览器会阻止跨域请求。

### Nginx 配置示例

在您的短链接服务的 Nginx server 块中添加以下配置：

```nginx
location / {
    # 添加 CORS 头
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
    
    # 处理 OPTIONS 预检请求
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization';
        add_header 'Content-Length' 0;
        add_header 'Content-Type' 'text/plain';
        return 204;
    }
    
    # 你的其他配置（如 proxy_pass 等）
    # ...
}
```

### 配置说明

- `Access-Control-Allow-Origin: *` - 允许所有域名访问（生产环境建议改为具体域名）
- `Access-Control-Allow-Methods` - 允许的 HTTP 方法
- `Access-Control-Allow-Headers` - 允许的请求头
- `always` 标志 - 确保即使在错误响应中也添加 CORS 头

### 应用配置

修改配置后，重载 Nginx：

```bash
# 测试配置
nginx -t

# 重载配置
nginx -s reload
# 或
systemctl reload nginx
```

## 🙏 致谢

- 原项目作者：[youshandefeiyang](https://github.com/youshandefeiyang)
- 最初项目作者：[CareyWang](https://github.com/CareyWang)

## 📄 许可证

本项目遵循原项目的许可证
