variable "region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "environment" {
  type        = string
  description = "Environment: dev, prod"
  default     = "dev"
}

variable "mqtt_server_image" {
  type        = string
  description = "MQTT Server Docker image"
}
