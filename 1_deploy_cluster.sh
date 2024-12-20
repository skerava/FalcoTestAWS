#!/bin/bash

# 设置变量
CONFIG_FILE="./cluster/cluster_config.yaml"
NGINX_CONFIG_FILE="nginx.yaml"

# 创建 EKS 集群
echo "Creating EKS cluster using configuration file: $CONFIG_FILE"
eksctl create cluster -f $CONFIG_FILE

# 检查集群创建状态
if [ $? -ne 0 ]; then
  echo "Failed to create EKS cluster."
  exit 1
fi

echo "EKS cluster created successfully."

# 应用 Nginx 配置
echo "Applying Nginx configuration from file: $NGINX_CONFIG_FILE"
kubectl apply -f $NGINX_CONFIG_FILE

# 检查 Nginx 配置应用状态
if [ $? -ne 0 ]; then
  echo "Failed to apply Nginx configuration."
  exit 1
fi

echo "Nginx configuration applied successfully."