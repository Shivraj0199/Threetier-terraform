# Threetier architecture using terraform
Threetier Web application using Terraform and AWS

## 🔧 Architecture Overview

**The 3-tier architecture includes:**

Presentation Layer (Web Tier): EC2 instances in a public subnet behind a Load Balancer.

Application Layer (app tier): EC2 instances in a private subnet.

Database Layer (db tier): RDS in a private subnet.

## 🛠 Step-by-Step Implementation

**Step 1:** Launch an ec2 instance whose name is Terrafrom in that server create the directory and supported files.

1. Make sure have terraform environment
- Terraform
- AWS CLI

**Step 2:** Create a directory the name of directory is Three-tier-architecture in that directory creates a supported files are.
1. Main.tf (web + app + db)

2. Variables.tf (Variables definition)

3. Terraform.tfvars

4. Output.tf (Output like public IP, DB endpoints)

**Step 3 :** Use the terraform commands to deploy the three-tier architecture.

1. terraform init
2. terraform plan
3. terraform apply

**Step 4 :** Create the index.html (sample webpage) in the web-tier instance and copy the public ip of server and paste them to the browser and check it works properly.



   
