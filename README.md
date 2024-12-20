## Deployment Note
### Launch a cluster
1. Launch a cluster
   ```
   eksctl create cluster -f cluster/cluster_config.yaml
   ```
2. Launch a Nginx pod
   ```
   kubectl apply -f nginx.yaml
   ```

### Deploy the fluent bit service to connect to Cloudwatch
1. Create a policy to connect to cloudwatch
   ```
 # 获取当前 EKS 集群名称
CLUSTER_NAME=$(kubectl config view --minify --output 'jsonpath={..cluster.server}' | sed 's~https://~~;s~\..*~~')

# 获取节点组名称 (NodeGroup)
NODEGROUP_NAME=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --query "nodegroups[0]" --output text)

# 获取节点角色 (NodeInstanceRole)
NODE_ROLE=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODEGROUP_NAME \
  --query "nodegroup.nodeRole" --output text | awk -F'/' '{print $NF}')

# 创建 IAM 策略 (如果尚未存在)
POLICY_ARN=$(aws iam create-policy --policy-name EKS-CloudWatchLogs \
  --policy-document file://./fluent-bit/aws/iam_role_policy.json 2>/dev/null || \
  aws iam list-policies --query "Policies[?PolicyName=='EKS-CloudWatchLogs'].Arn" --output text)

# 将策略附加到节点角色
aws iam attach-role-policy --role-name $NODE_ROLE --policy-arn $POLICY_ARN

echo "Attached policy $POLICY_ARN to role $NODE_ROLE for EKS cluster $CLUSTER_NAME."

   ```
