output "bootstrap_server_public_ip" {
  description = "Public IP of the Bootstrap Server"
  value       = aws_instance.bootstrap_server.public_ip
}

output "jenkins_server_public_ip" {
  description = "Public IP of the Bootstrap Server"
  value       = aws_instance.jenkins_server.public_ip
}

output "sonarqube_server_public_ip" {
  description = "Public IP of the Bootstrap Server"
  value       = aws_instance.sonarqube_server.public_ip
}
