#!/bin/bash

# 添加 Falco Helm 仓库
echo "Adding Falco Helm repository..."
helm repo add falcosecurity https://falcosecurity.github.io/charts

# 更新 Helm 仓库索引
echo "Updating Helm repository index..."
helm repo update

# 安装 Falco
echo "Installing Falco using values from falco_config/values.yaml..."
helm install falco -f falco_config/values.yaml falcosecurity/falco

# 检查 Falco 安装状态
if [ $? -ne 0 ]; then
  echo "Failed to install Falco."
  exit 1
fi

echo "Falco installed successfully."