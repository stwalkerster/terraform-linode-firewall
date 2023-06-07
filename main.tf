terraform {
  required_version = "~> 1.3"

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 1.29"
    }
  }
}

data "linode_instances" "linode" {
  count = var.linode == null ? 0 : 1

  filter {
    name   = "label"
    values = [var.linode]
  }
}

resource "linode_firewall" "firewall" {
  label           = var.name
  inbound_policy  = var.inbound_policy
  outbound_policy = var.outbound_policy
  linodes         = var.linode == null ? null : [data.linode_instances.linode[0].instances[0].id]
  disabled        = var.disabled

  dynamic "inbound" {
    for_each = [for s in var.firewall_rules : s if contains(s.protocol, "TCP")]
    iterator = rule

    content {
      label    = rule.value.comment
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = join(",", rule.value.ports)
      ipv4     = rule.value.public ? ["0.0.0.0/0"] : rule.value.ipv4
      ipv6     = rule.value.public ? ["::/0"] : rule.value.ipv6
    }
  }

  dynamic "inbound" {
    for_each = [for s in var.firewall_rules : s if contains(s.protocol, "UDP")]
    iterator = rule

    content {
      label    = rule.value.comment
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = join(",", rule.value.ports)
      ipv4     = rule.value.public ? ["0.0.0.0/0"] : rule.value.ipv4
      ipv6     = rule.value.public ? ["::/0"] : rule.value.ipv6
    }
  }

  dynamic "inbound" {
    for_each = [for s in var.firewall_rules : s if contains(s.protocol, "ICMP")]
    iterator = rule

    content {
      label    = rule.value.comment
      action   = "ACCEPT"
      protocol = "ICMP"
      ipv4     = rule.value.public ? ["0.0.0.0/0"] : rule.value.ipv4
      ipv6     = rule.value.public ? ["::/0"] : rule.value.ipv6
    }
  }
}
