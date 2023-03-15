# private_apps_ec2_ecs

# Step one - prerequisites 

- AWS CLI
- IAM user with permissions to deploy EC2, VPC, ECS, ECR resources
- Terraform (latest)
- Clone repo to local directory (SSH access using Midway - https://w.amazon.com/bin/view/AWS/Teams/WWPS/TSD/GitLab#HSettingupgitAccess)

## Step Two - ECR deployment
ECR is required to be deployed first ready for the infra deployment. The output file will display a unique URI for the created ECR that includes the target AWS account name. Copy this output and copy it to ecs.tf line 35.

- Browse to /ecr_build
- run - aws configure with IAM credentials
- terraform init
- terraform apply
- copy account number out of the output text
- add account number to line 35 in ecs.tf (in the root) - save

example - image     = "123456789.dkr.ecr.us-west-2.amazonaws.com/consumer2-ec2-web:latest"

## Step Three - Build Docker image
A docker image is needed to be used with ECS, the image is a basic website written in node.js.

- browse to /ecs_app folder
- run
    - npm init --y
    - npm install express
- this will create the files needed
- to test the app locally
    - node server.js 
    - open a new terminal
        - curl http://localhost:8080
        - this will return "consumer2 app running on ECS"
- run docker build command
    - docker build . -t consumer2/app
    - to test docker is running
        - docker run -p 8080:8080 -d consumer2/app
        - open a new terminal
            - curl http://localhost:8080
            - this will return "consumer2 app running on ECS"   
- once complete logon to ECR - add the account number found in step 2
    - aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-west-2.amazonaws.com
- once logged in push the docker to ECR (change the account number)
    - docker push 123456789.dkr.ecr.us-west-2.amazonaws.com/consumer2-ec2-web:latest

## Step Four - Build main infrastructure
The next step is to deploy the main infrastructure. The diagram displays whats is deployed.

<add image>

- browse to root directory
- terraform init
- terraform apply

## Step Five - Test access
Once deployed there will be an EC2 instance in each Consumer VPC, they will have internet access via the Network VPC but no path between each other. Network path is blocked on the TGW between Consumer1 and consumer2 VPCs. SSM agents are configured on the EC2 and can be used for connect to the local instances on private subnets. From here the access can be tested.

- Open instance - Consumer1-ec2-web
    - Connect - SSM console
    - run
        - curl http://localhost 
            - Data will return "Consumer1 app running on EC2"
    - Record (consumer2-ec2-web) private IP running in consumer2 VPC
        - Still on the instance SSM session run
        - curl http://consumer2-ec2-private-ip
            - This will time out

To test ECS
- Open instance - consumer2-ec2-web
    - connect - SSM console
    - record private ALB DNS name (consumer2-web-alb) 
    - run
        - curl http://local-dns-name:8080
        - Data will return "consumer2 app running on ECS"
