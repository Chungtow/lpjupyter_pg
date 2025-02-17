# 1、项目简介
`lpjupyter_pg`是一个基于`JupyterHub`的个人开发者环境镜像构建项目。该项目使用`Docker`构建一个包含`JupyterHub`、`JupyterLab`和其他必要依赖项的`Docker`镜像，适用于多用户管理和开发环境部署，支持定时任务调度。

# 2、目录结构
```plain
.
├── build.sh
├── Dockerfile
├── jupyterhub_config.txt
├── LICENSE
└── README.md
```

# 3、前提条件
在开始之前，请确保满足以下前提条件：

1. **操作系统**：Linux 系统（推荐 Ubuntu 20.04 或更高版本）。
2. **Docker 安装**：系统上已安装并配置好 Docker。
3. **网络畅通**：确保机器可以访问互联网，以便下载必要的依赖项。

# 4、使用说明
### 步骤一：克隆项目
你可以通过 HTTPS 或 SSH 方式克隆项目到本地：

#### HTTPS 方式：
```git
git clone https://github.com/Chungtow/lpjupyter_pg.git
```

#### SSH 方式：
```git
git clone git@github.com:Chungtow/lpjupyter_pg.git
```

### 步骤二：进入项目目录
切换到克隆下来的项目目录：

```bash
cd lpjupyter_pg
```

### 步骤三：构建镜像
执行 `build.sh`脚本来构建 Docker 镜像。默认情况下，镜像名称为 `liangpu/jupyter:pg`

#### 直接使用默认镜像名称：
```bash
./build.sh
```

#### 使用自定义镜像名称：
```bash
./build.sh <自定义镜像名>
```

在构建过程中，你可以选择以下两种方式之一：

1. **一次性构建**
2. **多阶段构建**

如果系统内存或硬盘空间有限，推荐多阶段构建方式，增加构建的成功率。

### 步骤四：验证镜像构建成功
构建完成后，可以通过以下命令查看已构建的镜像：

```bash
docker images
```

你应该能看到名为 `liangpu/jupyter:pg`（或你自定义的镜像名称）的镜像。

### 步骤五：启动容器
可根据需求选择合适的启动方式：

#### 启动方式一：交互式创建容器实例，直接启动 JupyterHub
```bash
docker run -it --name myjupyter -p 8000:8000 liangpu/jupyter:pg
```

#### 启动方式二：交互式创建容器实例后，手动启动 JupyterHub
1. **交互式启动容器**

```bash
docker run -it --name myjupyter -p 8000:8000 liangpu/jupyter:pg /bin/bash
```

2. **手动启动 JupyterHub**： 在容器内运行以下命令启动 JupyterHub：

```bash
/start.sh
```

#### 启动方式三：守护式启动
以守护进程模式启动容器：

```bash
docker run -d --name myjupyter -p 8000:8000 liangpu/jupyter:pg
```

#### 启动方式四：挂载数据卷，设置自动重启
挂载宿主机上的数据卷，并设置容器自动重启：

```bash
docker run -d --name myjupyter \
  -p 8000:8000 \
  --restart always \
  -v /home/jupyterusers:/home/jupyterusers \
  liangpu/jupyter:pg
```

# 常见问题及解决方法
#### 1. Docker 安装问题
+ **问题描述**：无法找到 Docker 命令。
+ **解决方法**：确认 Docker 是否正确安装。

#### 2. 构建失败
+ **问题描述**：在构建过程中遇到错误。
+ **解决方法**：检查输出日志中的错误信息，并确保所有依赖项都已正确安装。可以尝试使用多阶段构建来优化构建过程。

#### 3. 容器启动失败
+ **问题描述**：容器无法正常启动。
+ **解决方法**：检查容器的日志输出，使用以下命令查看容器日志：

```bash
docker logs myjupyter
```

根据日志中的错误提示进行修复。

#### 4. 端口冲突
+ **问题描述**：端口 8000 已被占用。
+ **解决方法**：选择其他未被占用的端口，例如：

```bash
docker run -d --name myjupyter -p 8001:8000 liangpu/jupyter:pg
```

# 贡献者
欢迎贡献代码！请先 fork 本项目并在本地进行修改，然后提交 pull request。

# 许可证
本项目遵循 MIT 协议。

