variable "yc_token" {
  description = "Short-lived IAM token; set through TF_VAR_yc_token and never commit it."
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud identifier"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder identifier"
  type        = string
}

variable "zone" {
  description = "Availability zone of the existing subnet"
  type        = string
}

variable "subnet_id" {
  description = "Existing subnet from the previous Yandex Cloud homework"
  type        = string
}
