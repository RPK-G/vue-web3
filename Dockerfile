# -----------------------------
# 阶段一：构建阶段 (Build Stage)
# -----------------------------
    FROM node:20.19.0-alpine AS build-stage

    # 设置工作目录
    WORKDIR /app
    
    # 复制 package.json 和 pnpm-lock.yaml (利用缓存)
    COPY package.json ./
    # 如果你有 lock 文件，建议也复制，没有就忽略这行
     COPY pnpm-lock.yaml ./ 
    
    # 安装依赖 (建议用 npm 或 pnpm)
    RUN pnpm install --frozen-lockfile --registry=https://registry.npmmirror.com
    
    # 复制所有源代码
    COPY . .
    
    # 打包构建 (生成 dist 目录)
    RUN pnpm run build
    
    # -----------------------------
    # 阶段二：生产运行阶段 (Production Stage)
    # -----------------------------
    FROM nginx:stable-alpine as production-stage
    
    # 从上一阶段复制构建产物 dist 到 Nginx 目录
    COPY --from=build-stage /app/dist /usr/share/nginx/html
    
    # 暴露 80 端口 (Render 会自动识别这个端口)
    EXPOSE 80
    
    # 启动 Nginx
    CMD ["nginx", "-g", "daemon off;"]