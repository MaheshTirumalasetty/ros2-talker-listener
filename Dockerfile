# Stage 1 — Base ROS 2 Environment
FROM ros:humble-ros-base AS base

# Set environment
ENV ROS_DISTRO=humble
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init || true
RUN rosdep update

# Stage 2 — Build Stage
FROM base AS builder

# Create workspace
WORKDIR /ros2_ws/src/talker_listener

# Copy package files
COPY package.xml .
COPY setup.py .
COPY setup.cfg .
COPY resource/ resource/
COPY talker_listener/ talker_listener/

# Install dependencies
WORKDIR /ros2_ws
RUN rosdep install \
    --from-paths src \
    --ignore-src \
    --rosdistro humble \
    -y

# Build the package
RUN /bin/bash -c \
    "source /opt/ros/humble/setup.bash && \
     colcon build \
     --event-handlers console_direct+"

# Stage 3 — Runtime Stage
FROM base AS runtime

# Copy built package from builder
COPY --from=builder /ros2_ws/install /ros2_ws/install

# Source ROS 2 and workspace on startup
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /ros2_ws/install/setup.bash" >> ~/.bashrc

# Set working directory
WORKDIR /ros2_ws

# Default command
CMD ["/bin/bash"]