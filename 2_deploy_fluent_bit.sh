#!/bin/bash

# 获取当前 EKS 集群名称
CLUSTER_NAME=$(kubectl config view --minify --output 'jsonpath={..cluster.server}' | sed 's~https://~~;s~\..*~~')
if [ -z "$CLUSTER_NAME" ]; then
  echo "Failed to get EKS cluster name."
  exit 1
fi

# 获取节点组名称 (NodeGroup)
NODEGROUP_NAME=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --query "nodegroups[0]" --output text)
if [ -z "$NODEGROUP_NAME" ]; then
  echo "Failed to get NodeGroup name."
  exit 1
fi

# 获取节点角色 (NodeInstanceRole)
NODE_ROLE=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME \
  --query "nodegroup.nodeRole" --output text | awk -F'/' '{print $NF}')
if [ -z "$NODE_ROLE" ]; then
  echo "Failed to get NodeInstanceRole."
  exit 1
fi

# 创建 IAM 策略 (如果尚未存在)
POLICY_ARN=$(aws iam create-policy --policy-name falco-CloudWatchLogs \
  --policy-document file://./cluster/cloudwatch_policy.json 2>/dev/null || \
  aws iam list-policies --query "Policies[?PolicyName=='falco-CloudWatchLogs'].Arn" --output text)
if [ -z "$POLICY_ARN" ]; then
  echo "Failed to create or get IAM policy."
  exit 1
fi

# 将策略附加到节点角色
aws iam attach-role-policy --role-name $NODE_ROLE --policy-arn $POLICY_ARN
if [ $? -ne 0 ]; then
  echo "Failed to attach policy $POLICY_ARN to role $NODE_ROLE."
  exit 1
fi

echo "Attached policy $POLICY_ARN to role $NODE_ROLE for EKS cluster $CLUSTER_NAME."