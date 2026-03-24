# Azure Container Registry Demo Application

这是一个简单的 Spring Boot 应用，用于演示如何构建并部署到 Azure Container Registry。

## 项目结构

对于你当前的情况（本地 Jenkins + 服务主体 + 远程后端），我推荐采用 **环境目录隔离 + 模块化** 的方式：

1. 创建 `modules/` 目录，将网络、AKS、数据库等抽象为模块。
2. 在 `environments/` 下建立 `dev`、`staging`、`prod` 子目录。
3. 每个子目录有自己的 `main.tf`（调用模块）、`terraform.tfvars` 和 `backend.tf`（不同 key）。
4. Jenkins Pipeline 通过参数化选择环境目录，执行 Terraform。

这种方式清晰、易于扩展，且状态文件按环境自然隔离，既避免了单个状态文件过大，也防止了跨环境误操作。

### 目录结构


terraform/
├── modules/                               # 可复用的模块目录
│   ├── networking/                         # 网络模块
│   │   ├── main.tf                         # 定义 VNet、子网等
│   │   ├── variables.tf                     # 输入变量（如地址空间）
│   │   └── outputs.tf                       # 输出（如子网 ID）
│   ├── aks/                                # AKS 模块
│   │   ├── main.tf                         # 定义 AKS 集群
│   │   ├── variables.tf                     # 输入变量（如节点数、版本）
│   │   └── outputs.tf                       # 输出（kubeconfig、集群 ID）
│   ├── ...                                  # 其他模块（如数据库、存储）
├── environments/                           # 环境配置目录
│   ├── dev/                                 # 开发环境
│   │   ├── main.tf                          # 调用模块，配置 dev 资源
│   │   ├── variables.tf                      # （可选）环境特有变量
│   │   ├── terraform.tfvars                   # 变量赋值（如环境名称、节点数）
│   │   ├── backend.tf                         # 后端配置（指向 dev 状态文件）
│   │   └── outputs.tf                         # （可选）环境输出
│   ├── staging/                              # 预发布环境（结构与 dev 相同）
│   │   └── ...
│   ├── prod/                                 # 生产环境
│   │   └── ...
├── .gitignore                              # 忽略敏感文件和临时文件
├── README.md                               # 项目说明
└── global/                                  # （可选）全局资源（如监控、日志）
└── ...

## prometheus实施顺序建议
1. 先做持久化：避免后续操作丢失数据。
2. 暴露 Grafana 并配置 HTTPS：便于访问。
3. 添加自定义告警：开始产生价值。
4. 逐步引入 ServiceMonitor：监控业务应用。
5. 最后考虑日志和追踪：根据需求决定。
6. 所有 Terraform 修改都需执行 terraform apply 生效
