
# Multi-Tier Web Application Architecture on AWS

This project outlines the design and deployment of a highly available, secure, and scalable multi-tier web application deployed within a custom AWS Virtual Private Cloud (VPC) across multiple Availability Zones.

---

## Architecture Overview

The infrastructure is designed to separate public-facing entry points from private application and database tiers, adhering to AWS best practices for security and high availability.

### 1. Networking (VPC & Subnets)
* **Custom VPC CIDR:** `10.0.0.0/16`
* **Availability Zones:** Two distinct AZs within the `us-east-1` region (`us-east-1a` and `us-east-1b`).
* **Public Subnets:** * `10.0.10.0/24` (us-east-1a)
    * `10.0.20.0/24` (us-east-1b)
* **Private Subnets:** * `10.0.100.0/24` (us-east-1a)
    * `10.0.200.0/24` (us-east-1b)
* **Routing:** * A **NAT Gateway** is launched in each public subnet to allow outbound internet traffic for instances in the private subnets.
    * A separate, dedicated route table is configured for the private subnets routing through the NAT Gateways.

### 2. Compute Tier (Web/App Instances)
* Two EBS-backed EC2 instances deployed across the two private subnets (`10.0.100.0/24` and `10.0.200.0/24`).
* **Security:**
    * EBS root volumes are fully **encrypted at rest**.
    * Instances use the Security Group `web-sg`. Inbound traffic rules strictly allow SSH (`22`), HTTP (`80`), and HTTPS (`443`), restricted further to accept HTTP traffic *only* from the Application Load Balancer.

### 3. Load Balancing & Scaling
* **Target Group (`web-tg`):** Enrolls the two application EC2 instances operating over port `80` (HTTP) for traffic forwarding and health checks.
* **Application Load Balancer (ALB):** Enabled across both public subnets to distribute inbound HTTP web traffic from the internet.
* **ALB Security Group (`alb-sg`):** Allows inbound HTTP public traffic from the internet and outbound HTTP traffic strictly to the application security group (`web-sg`).
* **Auto Scaling Group (ASG):** Implements a target tracking policy ensuring elasticity, cost efficiency, and automated replacement of unhealthy instances.

### 4. Database Tier
* A **Multi-AZ RDS Database** deployment for automated failover and high availability.
* **Security:** Database security group rules are locked down to *only* accept traffic originating from the `web-sg` tier.

---

## User Data Scripts

The following Bash scripts are executed automatically at launch time to initialize Apache (`httpd`) and serve a basic verification page on each instance.

### Web/App Instance 1
```bash
#!/bin/bash
yum update -y
yum install httpd -y     # Installs apache (httpd) service
systemctl start httpd    # Starts httpd service
systemctl enable httpd   # Enables httpd to auto-start at system boot
echo "This is server 1 in AWS Region US-EAST-1 in AZ US-EAST-1A" > /var/www/html/index.html
