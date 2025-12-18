# EC2 Instance and CloudWatch Alarm Setup

## Launch EC2 Instance

Create an EC2 instance named **xfusion-ec2** using any appropriate **Ubuntu AMI**.

---

## Create CloudWatch Alarm

Create a CloudWatch alarm named **xfusion-alarm** with the following specifications:

- **Statistic:** Average  
- **Metric:** CPU Utilization  
- **Threshold:** ≥ 90% for **1 consecutive 5-minute period**  
- **Alarm Actions:** Send a notification to **xfusion-sns-topic**

---
