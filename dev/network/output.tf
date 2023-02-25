output "dev_network_id" {
  value = aws_vpc.network.id
}

output "dev_subnet_az1_id" {
  value = aws_subnet.subnet.id
}

output "dev_subnet_az2_id" {
  value = aws_subnet.subnet_az2.id
}

output "dev_subnet_az3_id" {
  value = aws_subnet.subnet_az3.id
}