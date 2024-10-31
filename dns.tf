# Reference the existing Route 53 Hosted Zone
data "aws_route53_zone" "my_dev_zone" {
  name =  var.domain_name
}

# Define the A record for your web app instance
resource "aws_route53_record" "web_app_a_record" {
  zone_id = data.aws_route53_zone.my_dev_zone.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 60

  # Point to the EC2 instance public IP
  records = [aws_instance.web_app.public_ip]



  depends_on = [aws_instance.web_app]
}
