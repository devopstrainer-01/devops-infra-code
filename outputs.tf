output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "instance_ids" {
  value = { for role, inst in aws_instance.workload : role => inst.id }
}

output "instance_public_ips" {
  value = { for role, inst in aws_instance.workload : role => inst.public_ip }
}

output "key_pair_created" {
  description = "True if Terraform generated a brand-new key pair this run; false if it reused an existing one"
  value       = local.create_key_pair
}

output "private_key_path" {
  description = "Path to the generated private key (.pem), only set when Terraform created a new key pair"
  value       = local.create_key_pair ? local.private_key_path : null
}
