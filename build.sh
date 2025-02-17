#!/bin/bash

# 设置默认的Dockerfile路径和上下文目录
DOCKERFILE_PATH="Dockerfile"
CONTEXT_DIR="."

# 默认的最终镜像名称
DEFAULT_FINAL_IMAGE_NAME="liangpu/jupyter:pg"

# 从命令行参数获取最终镜像名称，如果没有提供则使用默认值
FINAL_IMAGE_NAME=${1:-$DEFAULT_FINAL_IMAGE_NAME}

# 定义其他阶段的镜像名称
BASE_IMAGE_NAME="liangpu/jupyter:base"
NODEJS_IMAGE_NAME="liangpu/jupyter:nodejs_setup"

# 函数：一次性构建
build_single_stage() {
    echo "开始一次性构建..."
    docker build -f "$DOCKERFILE_PATH" -t "$FINAL_IMAGE_NAME" "$CONTEXT_DIR"
}

# 函数：多阶段构建
build_multi_stage() {
    echo "开始多阶段构建..."

    # 构建基础环境阶段
    docker build -f "$DOCKERFILE_PATH" --target base -t "$BASE_IMAGE_NAME" "$CONTEXT_DIR"
    
    # 构建Node.js及其相关工具安装阶段
    docker build -f "$DOCKERFILE_PATH" --target nodejs_setup -t "$NODEJS_IMAGE_NAME" "$CONTEXT_DIR"
    
    # 构建最终阶段
    docker build -f "$DOCKERFILE_PATH" --target final -t "$FINAL_IMAGE_NAME" "$CONTEXT_DIR"

    # 删除中间镜像
    echo "删除中间镜像..."
    docker image rm "$BASE_IMAGE_NAME" "$NODEJS_IMAGE_NAME"
}

# 主程序逻辑
echo "请选择构建方式:"
echo "1. 一次性构建"
echo "2. 多阶段构建"
read -p "请输入选项 (1 或 2): " choice

case $choice in
    1)
        build_single_stage
        ;;
    2)
        build_multi_stage
        ;;
    *)
        echo "无效的选项，请输入 1 或 2."
        ;;
esac
