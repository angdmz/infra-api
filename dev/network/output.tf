output "dev_network_id" {
  value = aws_vpc.network.id
}

output "dev_subnet_id" {
  value = aws_subnet.subnet.id
}