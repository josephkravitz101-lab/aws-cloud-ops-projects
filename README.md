# AWS Cloud Ops Projects

This repository contains hands-on AWS projects I built while transitioning from Ad Operations into **Cloud Operations / DevOps Engineering**.

All projects focus on practical, production-relevant skills: Infrastructure as Code, CI/CD, containerization, monitoring, and secure networking.

## AWS Certification

**AWS Certified Cloud Practitioner (CLF-C02)** — April 2026

[![AWS Certified Cloud Practitioner](https://img.shields.io/badge/AWS%20Certified-Cloud%20Practitioner-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://www.credly.com/badges/edce3c9b-1890-4ba3-8a6d-bd98d6f4f99a/public_url)

## Projects

### Project 1: Terraform Elastic Infrastructure with Dockerized Application & CI/CD
**Most Comprehensive Project**

Engineered a complete, production-ready environment featuring:
- Terraform IaC with Auto Scaling Group + Target Tracking Policies
- **Dockerized Bash web application** (lightweight server using netcat)
- Full CI/CD pipeline with GitHub Actions (Terraform Plan + Docker Build & Push)
- Secure keyless authentication using **OIDC**
- S3 Remote Backend + DynamoDB State Locking
- CloudWatch monitoring + SNS alerts
- [View Project →](./project-1-terraform-dockerized-app)

### Console-Based Projects (Foundational AWS Skills)
### Project 2: S3 Cost Optimization with Lifecycle Rules & Budgets
- Enabled S3 bucket versioning for data protection
- Created lifecycle rules to automatically transition objects to cheaper storage classes (Standard-IA after 30 days, Glacier after 90 days)
- Set up AWS Budgets with 80% alert threshold
- [View Project →](./project-2-s3-cost-optimization)

### Project 3: Secure VPC Architecture
- Built a custom VPC with public and private subnets
- Configured route tables and security groups for proper isolation
- Added S3 Gateway VPC Endpoint for private access to S3
- Launched EC2 instances in both public and private subnets
- [View Project →](./project-3-secure-vpc-architecture)

## Technologies Used

- **IaC & Orchestration:** Terraform, GitHub Actions
- **Containerization:** Docker
- **Cloud:** AWS (EC2, ASG, VPC, S3, CloudWatch, SNS, IAM)
- **Security:** OIDC, Security Groups
- **Observability:** CloudWatch Alarms

## About Me
- **AWS Certified Cloud Practitioner (CLF-C02)** – April 2026
- Former Ad Operations Manager with strong experience in platform monitoring, troubleshooting, and optimization at scale
- Transitioning into Cloud Operations / DevOps roles in NYC

---

**Last updated:** June 2026