variable "vpc_config" {
  description = "CIDR and name for the VPC"
  type = object({
    cidr_block = string
    name = string
  })

  validation {
    condition = length(trimspace(var.vpc_config.name)) > 0
    error_message = "VPC name must be provided"
  }

  validation {
    condition = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "Invalid CIDR Format - ${var.vpc_config.cidr_block}"
  }
}

#For subnet
############### FORMAT ########################
# {
#   <subnet_name> = {
#     cidr_block = ""
#     availability_zone = ""
#     public = <true/false>
#   }
# }

variable "subnet_config" {
  description = "Configuration for subnets with cidr block and az"
  type = map(object({
    cidr_block = string
    az = string
    public = optional(bool, false)
    assign_public_ip = optional(bool, false)
    allow_nat = optional(bool, false)
  }))

  validation {
    condition = alltrue([
      for subnet_name, config in var.subnet_config : 
      length(trimspace(config.cidr_block)) > 0 && 
      can(cidrnetmask(config.cidr_block)) &&
      can(regex(
        "^(?:(?:25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d)(?:/(?:3[0-2]|[12]?\\d))$", 
        config.cidr_block
      ))
    ])
    error_message = "Invalid CIDR format(s) found:\n${
    join("\n", [
      for subnet_name, config in var.subnet_config : 
      can(cidrnetmask(config.cidr_block)) && can(regex("^(?:(?:25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d)(?:/(?:3[0-2]|[12]?\\d))$", config.cidr_block)) ? "" : 
      "  - ${subnet_name}: ${config.cidr_block} (invalid format)"
    ])}"
  }

  validation {
    condition = alltrue([
      for subnet_name, config in var.subnet_config : 
      length(trimspace(config.az)) > 0
    ])
    error_message = "Availability Zone cannot be blank"
  }

  validation {
    condition = alltrue([
      for subnet_name, config in var.subnet_config : 
      length(trimspace(subnet_name)) > 0
    ])
    error_message = "Subnet Name cannot be blank"
  }

  validation {
    condition = alltrue([
      for _, config in var.subnet_config:
      !( (config.public == false) && (config.assign_public_ip == true) )
    ])
    error_message = "Private Subnet cannod be assigned a public Ip"
  }

  validation {
    condition = alltrue([
      for _, config in var.subnet_config:
      !(config.public && config.allow_nat)
    ])
    error_message = "Public Subnet cannod be routed through a NAT gateway"
  }

  validation {
    condition = (
      anytrue([for config in var.subnet_config : config.allow_nat])
        ? anytrue([for config in var.subnet_config : config.public])
        : true
    )
    error_message = "If you enable NAT gateway, you must also define at least one public subnet."
  }
}

variable "custom_tags" {
  description = "Additional tags to apply to all resources"
  type = map(string)
  default = {}
}