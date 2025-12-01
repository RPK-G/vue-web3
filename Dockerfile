# -----------------------------
# 阶段一：构建阶段
# -----------------------------
    FROM node:20.19.0-alpine AS build-stage

    WORKDIR /app
    
    # 【核心修复】不折腾 corepack 了，直接用 npm 安装 pnpm
    # 这一行必须在 pnpm install 之前！
    RUN npm install -g pnpm
    
    # 复制配置文件
    COPY package.json pnpm-lock.yaml ./
    
    # 安装依赖
    # 注意：如果你的项目里没有 pnpm-lock.yaml，请去掉 --frozen-lockfile
    RUN pnpm install --frozen-lockfile --registry=https://registry.npmmirror.com
    
    # 复制源码并打包
    COPY . .
    RUN pnpm run build
    
    # -----------------------------
    # 阶段二：生产运行阶段
    # -----------------------------
    FROM nginx:stable-alpine as production-stage
    
    # 从上一阶段复制构建产物
    COPY --from=build-stage /app/dist /usr/share/nginx/html
    
    # 暴露端口
    EXPOSE 80
    
    # 启动 Nginx
    CMD ["nginx", "-g", "daemon off;"]