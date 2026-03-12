pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: '选择要部署的环境'
        )
    }

    environment {
        // 从 Jenkins 凭据中读取 Azure 服务主体信息
        ARM_CLIENT_ID       = credentials('azure-client-id')
        ARM_CLIENT_SECRET   = credentials('azure-client-secret')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_TENANT_ID       = credentials('azure-tenant-id')
        // 存储账户访问密钥（用于后端）
        ARM_ACCESS_KEY      = credentials('azure-sa-access-key')

        // 可选：如果模块需要订阅 ID 变量，可以通过 TF_VAR_ 注入
        TF_VAR_main_subscription_id = "${ARM_SUBSCRIPTION_ID}"
    }

    stages {
        stage('Checkout') {
            steps {
                // 从 GitHub 拉取代码（需要提前配置凭据）
                git branch: 'main',
                    url: 'https://github.com/你的组织/你的仓库.git',
                    credentialsId: 'github-token'
            }
        }

        stage('切换到对应环境目录') {
            steps {
                script {
                    // 根据参数切换到 environments/${ENVIRONMENT}
                    dir("environments/${params.ENVIRONMENT}") {
                        // 后续 stage 会在此目录下执行
                        // 但 dir 的作用域有限，所以需要在每个 stage 中重新进入
                        // 我们可以在每个 Terraform stage 中显式使用 dir
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform fmt -check'
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    // 生成计划文件，并保存
                    sh 'terraform plan -out=tfplan'
                }
            }
            post {
                success {
                    // 归档计划文件，方便查看
                    archiveArtifacts artifacts: "environments/${params.ENVIRONMENT}/tfplan"
                }
            }
        }

        stage('Approval') {
            when {
                // 仅当环境为 prod 时暂停等待审批
                expression { params.ENVIRONMENT == 'prod' }
            }
            steps {
                input message: "是否批准将计划应用到生产环境？请确认变更。", ok: '批准'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
            post {
                success {
                    // 可选：获取输出（如 kubeconfig）并保存
                    script {
                        dir("environments/${params.ENVIRONMENT}") {
                            // 如果存在 kubeconfig 输出，可以写入文件供后续阶段使用
                            sh 'terraform output -raw aks_kubeconfig > kubeconfig || true'
                        }
                        // 使用 stash 保留 kubeconfig 供后续部署任务
                        stash name: 'kubeconfig', includes: "environments/${params.ENVIRONMENT}/kubeconfig", allowEmpty: true
                    }
                }
            }
        }

        // 示例：后续部署阶段（需要时取消注释）
        // stage('Deploy to AKS') {
        //     when {
        //         expression { fileExists("environments/${params.ENVIRONMENT}/kubeconfig") }
        //     }
        //     steps {
        //         unstash 'kubeconfig'
        //         script {
        //             env.KUBECONFIG = "${WORKSPACE}/environments/${params.ENVIRONMENT}/kubeconfig"
        //         }
        //         sh 'kubectl get nodes'  // 验证连接
        //         // 在此添加你的部署命令
        //     }
        // }
    }

    post {
        always {
            // 清理工作空间，避免残留文件影响下次构建
            cleanWs()
        }
        success {
            echo "环境 ${params.ENVIRONMENT} 基础设施变更成功！"
        }
        failure {
            echo "环境 ${params.ENVIRONMENT} 基础设施变更失败，请检查日志。"
        }
    }
}