# 项目描述：Azure DevOps - 基础设施即代码 + 应用部署 + 可观测性

## 📖 项目概述

本项目展示了如何使用 **Jenkins + GitHub + Terraform** 在 **Azure** 上实现端到端的自动化运维。从创建 AKS 集群，到部署监控系统（Prometheus + Grafana），再到自动构建和部署 Spring Boot 应用，并实现应用指标的可观测性。所有配置均通过代码管理，符合 GitOps 和 IaC 最佳实践。

### 🎯 核心目标
- 自动化创建 AKS 集群（包括 VNet、子网）
- 部署 Prometheus + Grafana 监控栈
- 构建并推送 Spring Boot 应用到 ACR
- 通过 ServiceMonitor 暴露应用指标
- 配置 Ingress 安全暴露监控 UI
- 通过 Jenkins Pipeline 实现 CI/CD 全流程

## 🧱 架构图

```
┌─────────────┐      ┌─────────────┐      ┌─────────────────────────┐
│   GitHub    │─────▶│   Jenkins   │─────▶│      Terraform          │
│ (代码仓库)  │      │ (CI/CD)     │      │ (基础设施即代码)         │
└─────────────┘      └─────────────┘      └───────────┬─────────────┘
                                                       │
                                                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Azure 资源组                             │
│  ┌──────────┐   ┌──────────────┐   ┌──────────────────────┐    │
│  │   VNet   │   │    AKS       │   │          ACR         │    │
│  │ + Subnet │   │  集群        │   │   (容器镜像仓库)      │    │
│  └──────────┘   └──────┬───────┘   └──────────────────────┘    │
│                         │                                        │
│                         ▼                                        │
│              ┌─────────────────────┐                            │
│              │  kube-prometheus    │                            │
│              │  - Prometheus       │                            │
│              │  - Grafana          │                            │
│              │  - Alertmanager     │                            │
│              └─────────┬───────────┘                            │
│                        │                                         │
│                        ▼                                         │
│              ┌─────────────────────┐                            │
│              │   Spring Boot App   │                            │
│              │   + ServiceMonitor  │                            │
│              └─────────────────────┘                            │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 主要功能

### 1. 基础设施自动化
- 使用 Terraform 管理 Azure 资源（资源组、VNet、子网、AKS 集群）
- 远程状态存储于 Azure Storage Account（带锁机制）
- 环境隔离：`dev` / `staging` / `prod` 目录

### 2. CI/CD 流水线
- Jenkins Pipeline 从 GitHub 拉取代码
- Maven 构建 Spring Boot 应用
- 使用 `az acr build` 在云端构建并推送镜像到 ACR
- 动态获取 AKS 凭证并部署应用

### 3. 可观测性
- 通过 Helm 部署 `kube-prometheus-stack`（Prometheus + Grafana）
- 持久化存储（Premium SSD）保留监控数据
- ServiceMonitor 自动发现应用指标端点
- 通过 Ingress + Let's Encrypt 安全暴露 Grafana 和 Prometheus

### 4. 应用监控
- Spring Boot 应用暴露 `/actuator/prometheus` 端点
- 自定义 PromQL 查询和 Grafana 仪表盘
- 告警规则配置（Alertmanager）

## 🛠️ 技术栈

| 类别          | 工具/平台                          |
|---------------|------------------------------------|
| 云平台        | Microsoft Azure                    |
| 基础设施编排  | Terraform                          |
| CI/CD         | Jenkins                            |
| 代码仓库      | GitHub                             |
| 容器镜像仓库  | Azure Container Registry (ACR)     |
| 容器编排      | Azure Kubernetes Service (AKS)     |
| 监控          | Prometheus + Grafana               |
| 应用框架      | Spring Boot (Java)                 |
| 构建工具      | Maven                              |
| 脚本语言      | Groovy (Jenkinsfile), Bash         |

## 📁 项目结构

```
.
├── Jenkinsfile                     # 流水线定义
├── Terraform/
│   ├── environments/
│   │   ├── dev/
│   │   │   ├── main.tf             # 根模块（网络、AKS、监控）
│   │   │   ├── variables.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── backend.tf
│   │   ├── staging/
│   │   └── prod/
│   └── modules/
│       ├── networking/             # VNet & 子网模块
│       └── aks/                    # AKS 集群模块
├── k8s/
│   ├── deployment.yaml             # 应用 Deployment & Service
│   └── servicemonitor.yaml         # Prometheus ServiceMonitor
└── src/                            # Spring Boot 应用源码
```

## 🔧 快速部署（开发者本地）

1. **克隆仓库**
   ```bash
   git clone https://github.com/yourname/devops-demo.git
   cd devops-demo
   ```

2. **配置 Azure 凭据**（服务主体）
   - 在 Jenkins 中添加凭据：`azure-client-id`, `azure-client-secret`, `azure-tenant-id`, `azure-subscription-id`

3. **修改环境变量**（`Terraform/environments/dev/terraform.tfvars`）
   ```hcl
   main_subscription_id = "your-sub-id"
   ```

4. **运行 Terraform 创建 AKS**
   ```bash
   cd Terraform/environments/dev
   terraform init
   terraform apply
   ```

5. **触发 Jenkins Pipeline**（或本地模拟）
   - Jenkins 会自动完成：构建应用 → 推送到 ACR → 部署到 AKS

6. **访问监控 UI**
   - Grafana: `http://<grafana-lb-ip>`
   - Prometheus: `http://prometheus.<ingress-ip>.nip.io`

## 📊 监控效果截图（示例）

> 由于无法直接嵌入图片，以下为文字描述：
> - Grafana 仪表盘展示 JVM 内存使用率、CPU 使用率、HTTP 请求速率
> - Prometheus Targets 页面显示 `demo-app` 状态为 `UP`
> - Alertmanager 中配置了 Pod 重启告警

## 注意

请确保代码通过 `terraform fmt` 和 `terraform validate`。
关于app部分放在了另一个仓库，需要可以联系我。

**项目地址**：https://github.com/2551390302/Azure-Jenkins-Terraform-Grafana
**联系方式**：2551390302@qq.com
