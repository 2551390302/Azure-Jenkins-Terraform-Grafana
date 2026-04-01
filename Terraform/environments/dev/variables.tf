variable "main_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "feishu_webhook_url" {
  description = "飞书群机器人的 Webhook 地址"
  type        = string
  sensitive   = true # 标记为敏感，Terraform 输出时隐藏
}