variable "firewall_rules" {
  type = map(object({
    comment  = string
    protocol = list(string)
    ports    = optional(list(number))
    ipv4     = optional(list(string), [])
    ipv6     = optional(list(string), [])
    public   = optional(bool, false)
  }))
}

variable "linode" {
  description = "Label of the Linode to apply this firewall to"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the firewall"
  type        = string
}

variable "disabled" {
  type    = bool
  default = false
}

variable "inbound_policy" {
  description = "Default inbound policy"
  type        = string
  default     = "DROP"
  validation {
    condition     = contains(["ACCEPT", "DROP"], var.inbound_policy)
    error_message = "inbound_policy must be either ACCEPT or DROP"
  }
}

variable "outbound_policy" {
  description = "Default outbound policy"
  type        = string
  default     = "ACCEPT"
  validation {
    condition     = contains(["ACCEPT", "DROP"], var.outbound_policy)
    error_message = "outbound_policy must be either ACCEPT or DROP"
  }
}
