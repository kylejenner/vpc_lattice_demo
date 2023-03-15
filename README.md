# vpc_lattice demo
Note - published date 15/03/23. VPC Lattice is in preview and only accessed by request, the AWS account used for the request will be enabled for VPC Lattice. Region is in the demo is us-west-2 due to preview. 

<details><summary>Prerequisites</summary>
<p>


# Step one - prerequisites 

- AWS CLI
- IAM user with permissions to deploy EC2, VPC, ECS, EKS, ECR resources
- Terraform (latest)
- Clone repo to local directory (SSH access using Midway - https://w.amazon.com/bin/view/AWS/Teams/WWPS/TSD/GitLab#HSettingupgitAccess)
- Docker desktop
- Kubectl (older version is the most stable) - curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/darwin/amd64/kubectl
- eskctl (latest)

</p>
</details>

<details><summary>Step 2 - ECR Deployment</summary>
<p>


## Step 2 - ECR deployment
ECR is required to be deployed first ready for the infra deployment. The output file will display a unique URI for the created ECR that includes the target AWS account name. 

Browse to /ecr_build
- run - 
```
aws configure with IAM credentials
```
```hcl 
terraform init
terraform apply
```
- copy account number out of the output text
- add account number to line 35 in /ecs.tf
- add account number to line 19 /eks/consumer3.yaml

example - image     = "123456789.dkr.ecr.us-west-2.amazonaws.com/repo:latest"

</p>
</details>

<details><summary>Step 3 - Build Docker Image</summary>
<p>

## Step 3 - Build Docker image
A docker image is needed to be used with ECS, the image is a basic website written in node.js.

browse to /ecs_app folder
- run
```
npm init --y
npm install express
```

- this will create the files needed
to test the app locally
```
node server.js
``` 
open a new terminal
```
curl http://localhost:8080
```
- this will return "consumer2 app running on ECS"

run docker build command
```
docker build . -t consumer2/app
```
to test docker is running
```
docker run -p 8080:8080 -d consumer2/app
```
open a new terminal
```
curl http://localhost:8080
```
- this will return "consumer2 app running on ECS"   
once complete logon to ECR - add the account number found in step 2
```
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-west-2.amazonaws.com
```
once logged in push the docker to ECR (change the account number)
```
docker push 123456789.dkr.ecr.us-west-2.amazonaws.com/consumer2-repo:latest
```
browse to /eks_app folder
- run
```
npm init --y
npm install express
```
- this will create the files needed
```
node server.js 
```
open a new terminal
```
curl http://localhost:8080
```
- this will return "consumer3 app running on EKS"
run docker build command
```
docker build . -t consumer3/app
```
- to test docker is running
```
docker run -p 8080:8080 -d consumer3/app
```
- open a new terminal
```
curl http://localhost:8080
```
- this will return "consumer3 app running on EKS" 
once complete logon to ECR - add the account number found in step 2
```
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-west-2.amazonaws.com
```
once logged in push the docker to ECR (change the account number)
```
docker push 123456789.dkr.ecr.us-west-2.amazonaws.com/consumer3-repo:latest
```

</p>
</details>

<details><summary>Step 4 - Build Main Infrastructure</summary>
<p>

## Step Four - Build main infrastructure
The next step is to deploy the main infrastructure.

browse to root directory
```hcl
terraform init
terraform apply
```

</p>
</details>

<details><summary>Step 5 - Test Access</summary>
<p>

## Step 5 - Test access
Once deployed there will be an EC2 instance in each Consumer VPC, they will have internet access via the Network VPC but no path between each other. Network path is blocked on the TGW between Consumer1, Consumer2 and Consumer3 VPCs. SSM agents are configured on the EC2 and can be used for connect to the local instances on private subnets. From here the access can be tested.

- open instance - Consumer1-ec2-web
    - connect - SSM console
    - run
```
curl http://localhost 
```
- CONNECTION "Consumer1 app running on EC2"
- record (consumer2-ec2-web) private IP running in consumer2 VPC
- Still on the instance SSM session run
```
curl http://consumer2-ec2-private-ip
```
- This will time out

To test ECS
- open instance - consumer2-ec2-web
 - connect - SSM console
 - record private ALB DNS name (consumer2-web-alb) 
 - run
"
curl http://local-dns-name:8080
"
- CONNECTION "consumer2 app running on ECS"

To test EKS
- browse to /eks_app folder
```
aws eks update-kubeconfig --name consumer3-eks-cluster --region us-west-2
```
- test access 
```
kubectl get svc
```
deploy test app 
```
kubectl apply -f consumer3.yaml
```
- see list of deployments 
```
kubectl get deployment -A
```
deploy frontend to test using a ELB 
```
kubectl apply -f frontend.yaml
```
- see list of services 
```
kubectl describe services frontend
```
- get private DNS name from the classic ELB that has been deployed in the account
- open instance - consumer3-ec2-web
  - connect - SSM console
  - record private ALB DNS name (consumer2-web-alb) 
  - run
```
curl http://private-dns-eks:8080
```
- CONNECTION "consumer3 app runnung on EKS"

</p>
</details>

<details><summary>Step 6 - VPC Lattice Deployment</summary>
<p>

## Step 6 - VPC Lattice deployment
The first step is to deploy a new gateway type instead of a standard LoadBalance ingress resource. The API gateway for Amazon (ACK) is required to directly communicate with VPC Lattice. With this gateway in place new services created in EKS are also created in VPC Lattice

browse to /eks_app folder
- remove frontend service 
```
kubectl remove service frontend
```
cluster requires the IAM OIDC provider to be configured for the cluster
```
eksctl utils associate-iam-oidc-provider --cluster consumer3-eks-cluster --approve
```
EKS cluster requires IAM policy assigned to get access to VPC Lattice
```
aws iam create-policy \
  --policy-name VPCLatticeControllerPolicy \
  --policy-document file://lattice-inline.json
```
deply a new namespce called "system"
```
kubectl apply -f namesystem.yaml
```
create a new service account for the cluster to use the new IAM policy
```
export VPCLatticeControllerIAMPolicyArn=$(aws iam list-policies \
  --query 'Policies[?PolicyName==`VPCLatticeControllerPolicy`].Arn' \
  --output text)
```
```
eksctl create iamserviceaccount \
  --cluster=consumer3-eks-cluster \
  --namespace=system \
  --name=gateway-api-controller \
  --attach-policy-arn=$VPCLatticeControllerIAMPolicyArn \
  --override-existing-serviceaccounts \
  --region us-west-2 \
  --approve
```

deploy ACK controller into the cluster 
```
kubectl apply -f deploy-v0.0.3.yaml
kubectl get pods -A
```
deploy a gateway class 
```
kubectl apply -f gatewayclass.yaml
kubectl get gatewayclass
```
deploy gateway object that links the new gateway class to VPC Lattice
```
kubectl apply -f consumer3-svc-network.yaml
kubectl get consumer3-svc-network -o yaml
```
this should return ARN of Lattice service network
   - troubleshoot "waiting for controller" - ```kubectl logs -n system api-gateway-name```
   - the logs will display any failures, look for IAM permissions if the service account has not applied correctly
   -  Apply Lattice permissions to EKS node assumed role to apply then outside of the service account

deploy HTTP route resource to apply the listeners (this can take up to 5 minutes)
```
kubectl apply -f consumer3-route.yaml
kubectl get httproute
```
- VPC Lattice will now display a new service linked to the VPC with a new target group

</p>
</details>

<details><summary>Step 7 - VPC Lattice Enrollment</summary>
<p>

## Step 7 - VPC Lattice enrollment

EKS service is now linked to VPC Lattice but we now need to add the other applications to be able to communicate. Note there is still no network connectivity between consumer VPCs - no TGW route or VPC peer.  

- browse to VPC Lattice Service console and copy DNS name from Lattice service 

open instance - consumer3-ec2-web 
```
curl http://service-dns from consumer3 instance
```
 - CONNECTION "consumer3 running on EKS"

open instance - consumer2-ec2-web
```
curl http://service-dns
```
- consumer2 instance times out

open VPC Lattice console again > Service and add consumer2 VPC association to Lattice service
- security group is required during the association, this is required to allow traffic from the Lattice fleet
- add security group "consumer1-ec2-web" for consumer1 VPC
- add security group "consumer2-ec2-web" for consumer2 VPC
    - The rule required on the security group is - Allow all from pl-0721453c7ac4ec009

open instance - consumer2-ec2-web
```
curl http://service-dns from consumer2 instance
```
  - CONNECTION "consumer3 running on EKS"

open instance - consumer1-ec2-web
```
curl http://service-dns from consumer1 instance
```
   - CONNECTION "consumer3 running on EKS"

</p>
</details>