output "image_id" {
  value = local.amimap[var.os]
}

output "image_ids" {
  value = local.amimap
}
