# ROS 2 Talker Listener CI/CD Pipeline

![CI Pipeline](https://github.com/MaheshTirumalasetty/ros2-talker-listener/actions/workflows/ros2_ci.yml/badge.svg)
![ROS Version](https://img.shields.io/badge/ROS-Humble-blue)
![Platform](https://img.shields.io/badge/Platform-x86__64%20%7C%20ARM64-orange)

## What is This Project?

This is a ROS 2 robotics package with a complete automated CI/CD pipeline. It demonstrates how robotics software is built, tested, and packaged for deployment on both cloud servers and embedded robot hardware.

This project mirrors the DevOps practices used for NVIDIA Isaac ROS development.

---

## What Does It Do?

The package contains two ROS 2 nodes that communicate with each other:

**Talker Node (Publisher)**
- Sends messages every 0.5 seconds
- Publishes on topic called chatter
- Like a radio station broadcasting

**Listener Node (Subscriber)**
- Receives messages automatically
- Subscribes to topic called chatter
- Like a radio listener tuning in
- Talker Node → → → chatter topic → → → Listener Node
(Publishing)                          (Receiving)

---

## CI/CD Pipeline

Every time code is pushed to GitHub, the pipeline runs automatically.

### Pipeline Flow

Developer pushes code
↓
GitHub Actions triggers automatically
↓
Job 1 — Build and Test
→ Install ROS 2 Humble
→ Install dependencies with rosdep
→ Build package with colcon
→ Run automated tests
↓
Job 2 — Docker Build (only runs if Job 1 passes)
→ Build Docker image for x86_64 (cloud servers)
→ Build Docker image for ARM64 (NVIDIA Jetson robots)
→ Build multi-architecture image

### Pipeline Results

| Job | Status | Time |
|-----|--------|------|
| build-and-test | ✅ Passing | ~4 minutes |
| docker-build | ✅ Passing | ~3 minutes |

---

## Multi-Architecture Support

This pipeline builds Docker images for TWO architectures simultaneously:

| Architecture | Hardware | Use Case |
|---|---|---|
| x86_64 | Cloud servers, laptops | Development and CI |
| ARM64 | NVIDIA Jetson | Physical robots |

This is the same challenge faced when building NVIDIA Isaac ROS packages that need to run on both cloud x86 systems and Jetson embedded platforms.

---

## Project Structure

```
ros2-talker-listener/
    talker_listener/
        talker_node.py      ← Publisher node
        listener_node.py    ← Subscriber node
        __init__.py
    resource/
        talker_listener     ← Package marker
    .github/
        workflows/
            ros2_ci.yml     ← CI/CD pipeline definition
    Dockerfile              ← Multi-stage Docker build
    package.xml             ← ROS 2 package dependencies
    setup.py                ← Python package configuration
    setup.cfg               ← Build configuration
    README.md               ← This file
```

## Key Technologies Used

| Technology | What It Does |
|---|---|
| ROS 2 Humble | Robotics middleware framework |
| colcon | Builds ROS 2 packages |
| rosdep | Installs ROS 2 dependencies |
| Docker Buildx | Builds multi-architecture images |
| QEMU | Emulates ARM64 on x86 for building |
| GitHub Actions | Runs CI/CD pipeline automatically |

---

## Dockerfile — Multi-Stage Build

The Dockerfile uses three stages:

```
Stage 1 — Base
→ Install ROS 2 and system tools
→ Initialize rosdep

Stage 2 — Builder
→ Copy source code
→ Install dependencies with rosdep
→ Build package with colcon
→ Has compilers and build tools (large)

Stage 3 — Runtime
→ Copy only final executables from builder
→ No build tools included
→ Small and lightweight for deployment
```

Multi-stage builds keep the final Docker image small and fast to deploy.

---

## How to Run Locally

### Prerequisites
- Docker Desktop installed on your machine

### Steps

```bash
# Step 1 - Pull ROS 2 Docker image
docker pull osrf/ros:humble-desktop

# Step 2 - Start container
docker run -it osrf/ros:humble-desktop

# Step 3 - Inside container, source ROS 2
source /opt/ros/humble/setup.bash

# Step 4 - Create workspace and build
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws
colcon build

# Step 5 - Source workspace
source install/setup.bash

# Step 6 - Run talker in Terminal 1
ros2 run talker_listener talker

# Step 7 - Run listener in Terminal 2
ros2 run talker_listener listener
```

---

## Connection to NVIDIA Isaac ROS

| This Repository | NVIDIA Isaac ROS |
|---|---|
| ROS 2 Humble packages | Isaac ROS GPU-accelerated packages |
| colcon build | colcon build |
| rosdep for dependencies | rosdep with custom NVIDIA rules |
| x86 and ARM64 builds | x86 and Jetson builds |
| GitHub Actions pipeline | GitLab CI and GitHub Actions |
| Multi-stage Dockerfile | Multi-stage Dockerfile |

---

## Pipeline Failure and Fix

During development the first pipeline run failed because ROS_DISTRO environment variable was not set. This caused rosdep to fail finding std_msgs package.

**Root Cause:** Missing ROS_DISTRO environment variable in CI agent

**Fix Applied:** Added global environment variable to workflow

```yaml
env:
  ROS_DISTRO: humble
```

This is a real example of triaging CI infrastructure issues versus code issues.

---

## About

Built by **Mahesh Tirumalasetti**

DevOps Engineer with experience building ROS 2 CI/CD pipelines at:
- **Amazon Robotics** — AWS CodePipeline, GitLab CI, ROS 2 Humble
- **Machina Labs** — Azure DevOps, GitHub Actions, ROS 2 Iron

This project was built to demonstrate hands-on understanding of ROS 2 DevOps practices applicable to NVIDIA Isaac ROS infrastructure.
