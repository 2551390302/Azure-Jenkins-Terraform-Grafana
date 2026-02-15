#!/bin/bash

# Azure Container Registry 配置
ACR_NAME="your-acr-name"  # 替换为你的ACR名称
IMAGE_NAME="azure-demo-app"
IMAGE_TAG="1.0.0"

echo "开始构建项目..."
mvn clean package -DskipTests

echo "登录到Azure Container Registry..."
az acr login --name $ACR_NAME

echo "构建Docker镜像..."
docker build -t $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG .

echo "推送镜像到ACR..."
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG

echo "构建完成！镜像已推送到: $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG"
