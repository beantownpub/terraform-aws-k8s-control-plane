# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

output "instance" {
  description = ""
  value       = aws_instance.control_plane
}

output "private_ipv4" {
  value = aws_instance.control_plane.private_ip
}
