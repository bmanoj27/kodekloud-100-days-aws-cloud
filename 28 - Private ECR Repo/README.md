# Amazon ECR Image Build and Push

## Task Overview

Create a private Amazon ECR repository and push a Docker image to it using an existing Dockerfile.

### Amazon ECR
- Create a **private ECR repository** named `devops-ecr`

### Docker Image
- A `Dockerfile` is available under the directory `/root/pyapp` on the **aws-client host**
- Build a Docker image using this Dockerfile
- Tag the image as **`latest`**

### Image Push
- Authenticate Docker to Amazon ECR
- Push the built Docker image to the `devops-ecr` repository

---
