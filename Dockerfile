# --- Build stage ---
FROM node:22.18.0-alpine3.22 AS build

# 拉取 git 依赖必需；如有原生模块再加 python3 make g++
RUN apk add --no-cache git

WORKDIR /app

# 先拷贝依赖清单利用缓存
COPY package.json yarn.lock ./
# node:22 已自带 yarn 1.x，无需再 npm i -g yarn
RUN yarn install --frozen-lockfile

# 再拷贝源码并构建
COPY . .
RUN yarn build

# --- Runtime stage ---
FROM nginx:1.24-alpine

# 复制构建产物
COPY --from=build /app/dist /usr/share/nginx/html

# 复制启动脚本
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

# 使用自定义启动脚本
ENTRYPOINT ["/docker-entrypoint.sh"]
