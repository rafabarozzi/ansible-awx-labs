 ## Create Cluster
 ```
eksctl create cluster --name=eksawx1 \
                      --version=1.25 \
                      --region=us-east-1 \
                      --zones=us-east-1a,us-east-1b \
                      --without-nodegroup 

# Get List of clusters
eksctl get cluster 
```
## Step-02: Create & Associate IAM OIDC Provider for our EKS Cluster

```
eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster eksawx1 \
    --approve
```
## Create EKS Node Group in Private Subnets

```
eksctl create nodegroup --cluster=eksawx1 \
                        --region=us-east-1 \
                        --name=eksawx1-ng-private1 \
                        --node-type=t3a.xlarge \
                        --nodes-min=2 \
                        --nodes-max=4 \
                        --node-volume-size=200 \
                        --ssh-access \
                        --ssh-public-key=MacKey \
                        --managed \
                        --asg-access \
                        --external-dns-access \
                        --full-ecr-access \
                        --appmesh-access \
                        --alb-ingress-access \
                        --node-private-networking 

# Get List of nodes
kubectl get nodes                         
```

## Install EBS CSI Drive

```
aws iam create-policy --policy-name Amazon_EBS_CSI_Driver --policy-document file://Amazon_EBS_CSI_Driver.json
```

- From output check arn:
```
"Arn": "arn:aws:iam::0000000000000:policy/Amazon_EBS_CSI_Driver"
```
- Get Worker node IAM Role ARN
```
kubectl -n kube-system describe configmap aws-auth
```
- From output check rolearn
```

eksctl-ekslab1-nodegroup-ekslab1-NodeInstanceRole-30QKFFP2QPUJ

rolearn: arn:aws:iam::00000000000000:role/eksctl-eksepinio1-nodegroup-eksep-NodeInstanceRole-0000000000000

# In this case the name of role is:
eksctl-eksepinio1-nodegroup-eksep-NodeInstanceRole-000000000000
```
- Associate the policy to that role
```
aws iam attach-role-policy --policy-arn arn:aws:iam::00000000000:policy/Amazon_EBS_CSI_Driver --role-name eksctl-eksepinio1-nodegroup-eksep-NodeInstanceRole-00000000000
```

- Deploy Amazon EBS Drive
```
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# Verify ebs-csi pods running
kubectl get pods -n kube-system
```

## Install Load Balancer Controller - Create Policy

- Download IAM Policy

```
curl -o iam_policy_latest.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

- Create IAM policy using policy downloaded
```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy_latest.json
```

- Make a note of Policy ARN
```

arn:aws:iam::410334805876:policy/AWSLoadBalancerControllerIAMPolicy

Policy ARN:  arn:aws:iam::000000000000:policy/AWSLoadBalancerControllerIAMPolicy
```

## Create an IAM role for the AWS LoadBalancer Controller and attach the role to the Kubernetes service account

- Create IAM Role using eksctl
```
kubectl get sa -n kube-system
kubectl get sa aws-load-balancer-controller -n kube-system
```
**Note: Nothing with name "aws-load-balancer-controller" should exist**

``` 
eksctl create iamserviceaccount \
  --cluster=eksdemo1 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::180789647333:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```
**Note: Replaced name, cluster and policy arn**

## Installing AWS Load Balance Controller

 - **Important-Note-1:** If you're deploying the controller to Amazon EC2 nodes that have restricted access to the Amazon EC2 instance metadata service (IMDS), or if you're deploying to Fargate, then add the following flags to the command that you run:

 ``` 
--set region=region-code
--set vpcId=vpc-xxxxxxxx
 ``` 

- **Important-Note-2:** If you're deploying to any Region other than us-west-2, then add the following flag to the command that you run, replacing account and region-code with the values for your region listed in Amazon EKS add-on container image addresses. 
 
- [Get Region Code and Account Info](https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html)
 ``` 
--set image.repository=account.dkr.ecr.region-code.amazonaws.com/amazon/aws-load-balancer-controller
 ``` 

```
# Add the eks-charts repository.
helm repo add eks https://aws.github.io/eks-charts

# Update your local repo to make sure that you have the most recent charts.
helm repo update

# Install the AWS Load Balancer Controller.
## Template
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=<region-code> \
  --set vpcId=<vpc-xxxxxxxx> \
  --set image.repository=<account>.dkr.ecr.<region-code>.amazonaws.com/amazon/aws-load-balancer-controller
``` 

**Note: Replace Cluster Name, Region Code, VPC ID, Image Repo Account ID and Region Code**

- Verify that the controller is installed and Webhook Service created

``` 
# Verify that the controller is installed.
kubectl -n kube-system get deployment 
kubectl -n kube-system get deployment aws-load-balancer-controller
kubectl -n kube-system describe deployment aws-load-balancer-controller

# Sample Output
kubectl get deployment -n kube-system aws-load-balancer-controller
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           27s
Kalyans-MacBook-Pro:08-01-Load-Balancer-Controller-Install kdaida$ 

# Verify AWS Load Balancer Controller Webhook service created
kubectl -n kube-system get svc 
kubectl -n kube-system get svc aws-load-balancer-webhook-service
kubectl -n kube-system describe svc aws-load-balancer-webhook-service

# Sample Output
Kalyans-MacBook-Pro:aws-eks-kubernetes-masterclass-internal kdaida$ kubectl -n kube-system get svc aws-load-balancer-webhook-service
NAME                                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
aws-load-balancer-webhook-service   ClusterIP   10.100.53.52   <none>        443/TCP   61m
Kalyans-MacBook-Pro:aws-eks-kubernetes-masterclass-internal kdaida$ 

# Verify Labels in Service and Selector Labels in Deployment
kubectl -n kube-system get svc aws-load-balancer-webhook-service -o yaml
kubectl -n kube-system get deployment aws-load-balancer-controller -o yaml
Observation:
1. Verify "spec.selector" label in "aws-load-balancer-webhook-service"
2. Compare it with "aws-load-balancer-controller" Deployment "spec.selector.matchLabels"
3. Both values should be same which traffic coming to "aws-load-balancer-webhook-service" on port 443 will be sent to port 9443 on "aws-load-balancer-controller" deployment related pods. 
``` 

- Verify AWS Load Balancer Controller Logs
```
# List Pods
kubectl get pods -n kube-system

# Review logs for AWS LB Controller POD-1
kubectl -n kube-system logs -f <POD-NAME> 
kubectl -n kube-system logs -f  aws-load-balancer-controller-86b598cbd6-5pjfk

# Review logs for AWS LB Controller POD-2
kubectl -n kube-system logs -f <POD-NAME> 
kubectl -n kube-system logs -f aws-load-balancer-controller-86b598cbd6-vqqsk 
``` 

- Verify AWS Load Balancer Controller k8s Service Account - Internals

```
# List Service Account and its secret
kubectl -n kube-system get sa aws-load-balancer-controller
kubectl -n kube-system get sa aws-load-balancer-controller -o yaml
kubectl -n kube-system get secret <GET_FROM_PREVIOUS_COMMAND - secrets.name> -o yaml
kubectl -n kube-system get secret aws-load-balancer-controller-token-5w8th 
kubectl -n kube-system get secret aws-load-balancer-controller-token-5w8th -o yaml
## Decoce ca.crt using below two websites
https://www.base64decode.org/
https://www.sslchecker.com/certdecoder

## Decode token using below two websites
https://www.base64decode.org/
https://jwt.io/
Observation:
1. Review decoded JWT Token

# List Deployment in YAML format
kubectl -n kube-system get deploy aws-load-balancer-controller -o yaml
Observation:
1. Verify "spec.template.spec.serviceAccount" and "spec.template.spec.serviceAccountName" in "aws-load-balancer-controller" Deployment
2. We should find the Service Account Name as "aws-load-balancer-controller"

# List Pods in YAML format
kubectl -n kube-system get pods
kubectl -n kube-system get pod <AWS-Load-Balancer-Controller-POD-NAME> -o yaml
kubectl -n kube-system get pod aws-load-balancer-controller-65b4f64d6c-h2vh4 -o yaml
Observation:
1. Verify "spec.serviceAccount" and "spec.serviceAccountName"
2. We should find the Service Account Name as "aws-load-balancer-controller"
3. Verify "spec.volumes". You should find something as below, which is a temporary credentials to access AWS Services
CHECK-1: Verify "spec.volumes.name = aws-iam-token"
  - name: aws-iam-token
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          audience: sts.amazonaws.com
          expirationSeconds: 86400
          path: token
CHECK-2: Verify Volume Mounts
    volumeMounts:
    - mountPath: /var/run/secrets/eks.amazonaws.com/serviceaccount
      name: aws-iam-token
      readOnly: true          
CHECK-3: Verify ENVs whose path name is "token"
    - name: AWS_WEB_IDENTITY_TOKEN_FILE
      value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token          
```

- Verify TLS Certs for AWS Load Balancer Controller - Internals
```
# List aws-load-balancer-tls secret 
kubectl -n kube-system get secret aws-load-balancer-tls -o yaml

# Verify the ca.crt and tls.crt in below websites
https://www.base64decode.org/
https://www.sslchecker.com/certdecoder

# Make a note of Common Name and SAN from above 
Common Name: aws-load-balancer-controller
SAN: aws-load-balancer-webhook-service.kube-system, aws-load-balancer-webhook-service.kube-system.svc

# List Pods in YAML format
kubectl -n kube-system get pods
kubectl -n kube-system get pod <AWS-Load-Balancer-Controller-POD-NAME> -o yaml
kubectl -n kube-system get pod aws-load-balancer-controller-65b4f64d6c-h2vh4 -o yaml
Observation:
1. Verify how the secret is mounted in AWS Load Balancer Controller Pod
CHECK-2: Verify Volume Mounts
    volumeMounts:
    - mountPath: /tmp/k8s-webhook-server/serving-certs
      name: cert
      readOnly: true
CHECK-3: Verify Volumes
  volumes:
  - name: cert
    secret:
      defaultMode: 420
      secretName: aws-load-balancer-tls
```

## Create IngressClass Resource

```
# Create IngressClass Resource
kubectl apply -f 01-Load-Balancer-Controller-Install/kube-manifests

# Verify IngressClass Resource
kubectl get ingressclass

# Describe IngressClass Resource
kubectl describe ingressclass my-aws-ingress-class
```
# Deploy External DNS

- Create IAM Policy

```
aws iam create-policy --policy-name AllowExternalDNSUpdates --policy-document file://AllowExternalDNSUpdates.json
```

- From output check arn:

```
"Arn": "arn:aws:iam::0000000000000:policy/AllowExternalDNSUpdates"
```

## Create IAM Role, k8s Service Account & Associate IAM Policy

```
eksctl create iamserviceaccount \
    --name service_account_name \
    --namespace service_account_namespace \
    --cluster cluster_name \
    --attach-policy-arn IAM_policy_ARN \
    --approve \
    --override-existing-serviceaccounts
```

eksctl create iamserviceaccount \
    --name external-dns \
    --namespace default \
    --cluster ekslab1 \
    --attach-policy-arn arn:aws:iam::410334805876:policy/AllowExternalDNSUpdates \
    --approve \
    --override-existing-serviceaccounts

- Verify external-dns service account, primarily verify annotation related to IAM Role

```
# List Service Account
kubectl get sa external-dns

# Describe Service Account
kubectl describe sa external-dns
```

**Observation:** *Verify the Annotations and you should see the IAM Role is present on the Service Account*

- Get IAM Service Accounts
```
eksctl get iamserviceaccount --cluster ekslab1
```
- From output check *ROLE ARN* for *external-dns*:

```
NAMESPACE	NAME				ROLE ARN
default		external-dns			arn:aws:iam::410334805876:role/eksctl-ekslab1-addon-iamserviceaccount-defau-Role1-1FCONLT4EI0IK
```

## Update External DNS Kubernetes manifest

- Copy the role-arn and replace at line no 9.

```
eks.amazonaws.com/role-arn: arn:aws:iam::180789647333:role/eksctl-eksdemo1-addon-iamserviceaccount-defa-Role1-JTO29BVZMA2N
```

- Change Line 61: Get latest Docker Image name

[Latest External DNS Image Name](https://github.com/kubernetes-sigs/external-dns/releases)

- Deploy Manifest

```
kubectl apply -f 02-Deploy-ExternalDNS/kube-manifests
```

```
# List pods (external-dns pod should be in running state)
kubectl get pods

# Verify Deployment by checking logs
kubectl logs -f $(kubectl get po | egrep -o 'external-dns[A-Za-z0-9-]+')
```

