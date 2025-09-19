# 使用更小的基础镜像
FROM ubuntu:22.04

ARG CUDA_VERSION=12.6

# 设置环境变量以避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive
ENV HSA_OVERRIDE_GFX_VERSION=10.3.0
ENV CUDA_VERSION=${CUDA_VERSION}

# 安装基础依赖和 Git、Python 环境
RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-pip python3-venv wget cmake ffmpeg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 克隆 ComfyUI 项目
RUN git clone https://github.com/RVC-Boss/GPT-SoVITS.git /GPT-SoVITS

# 创建并激活虚拟环境
RUN python3 -m venv /venv

# 升级虚拟环境中的 pip
RUN /venv/bin/pip install --upgrade pip

# 激活虚拟环境并安装 PyTorch 相关依赖
RUN /venv/bin/pip install --no-cache-dir torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/rocm6.2

# 安装 ComfyUI 项目依赖
WORKDIR /GPT-SoVITS
RUN /venv/bin/pip install --no-cache-dir -r extra-req.txt --no-deps
RUN /venv/bin/pip install --no-cache-dir -r requirements.txt

# 暴露服务端口并设置默认启动命令
EXPOSE 9871 9872 9873 9874 9880
EXPOSE 8188
CMD ["/venv/bin/python3", "webui.py"]