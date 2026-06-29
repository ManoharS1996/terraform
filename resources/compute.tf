data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_security_group" "public_http_traffic" {
  name        = "public-http-traffic"
  description = "Allow SSH, HTTP and HTTPS traffic"
  vpc_id      = "vpc-0eaeba92786e9f157"

  tags = {
    Name = "public-http-traffic"
  }
}

# SSH
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.public_http_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# HTTP
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.public_http_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# HTTPS
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.public_http_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Outbound
resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.public_http_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "web" {

  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = "t3.micro"
  subnet_id                   = "subnet-0549bb5b7ee21b9c1"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.public_http_traffic.id
  ]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = <<-EOF
#!/bin/bash

apt-get update -y
apt-get install nginx -y

systemctl enable nginx
systemctl start nginx

cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>AWS DevOps Portfolio</title>

<style>

*{
margin:0;
padding:0;
box-sizing:border-box;
font-family:'Segoe UI',sans-serif;
}

body{

background:linear-gradient(135deg,#0f172a,#1d4ed8,#16a34a);
background-size:400% 400%;
animation:bg 10s ease infinite;

display:flex;
justify-content:center;
align-items:center;

min-height:100vh;

}

@keyframes bg{

0%% { background-position:0%% 50%%; }
50%% { background-position:100%% 50%%; }
100%% { background-position:0%% 50%%; }

}

.container{

width:900px;
max-width:95%;

background:white;

border-radius:25px;

padding:50px;

text-align:center;

box-shadow:0 30px 80px rgba(0,0,0,.30);

}

.logo{

width:120px;
height:120px;

background:#ff9900;

border-radius:50%;

display:flex;

justify-content:center;
align-items:center;

margin:auto;

font-size:45px;
font-weight:bold;

color:white;

margin-bottom:30px;

}

h1{

font-size:42px;
color:#16a34a;

margin-bottom:15px;

}

h2{

color:#2563eb;

margin-bottom:30px;

}

.desc{

font-size:18px;

line-height:1.8;

color:#555;

margin-bottom:35px;

}

.grid{

display:grid;

grid-template-columns:repeat(3,1fr);

gap:20px;

margin-top:25px;

}

.card{

background:#f8fafc;

padding:20px;

border-radius:15px;

border:1px solid #ddd;

transition:.3s;

}

.card:hover{

transform:translateY(-8px);

box-shadow:0 12px 25px rgba(0,0,0,.15);

}

.card h3{

color:#2563eb;

margin-bottom:10px;

}

.card p{

color:#555;

}

.badges{

margin-top:35px;

display:flex;

justify-content:center;

flex-wrap:wrap;

gap:15px;

}

.badge{

background:#2563eb;

padding:12px 20px;

border-radius:50px;

color:white;

font-weight:bold;

}

.status{

margin-top:40px;

background:#dcfce7;

padding:20px;

border-radius:12px;

color:#166534;

font-size:20px;

font-weight:bold;

}

.footer{

margin-top:35px;

color:#666;

line-height:1.8;

}

</style>

</head>

<body>

<div class="container">

<div class="logo">AWS</div>

<h1>Ubuntu EC2 Successfully Deployed</h1>

<h2>Terraform Infrastructure as Code</h2>

<p class="desc">

This Ubuntu EC2 instance has been provisioned automatically using Terraform Infrastructure as Code (IaC).
Nginx has been installed and configured successfully during deployment using cloud-init.

</p>

<div class="grid">

<div class="card">
<h3>AWS Cloud</h3>
<p>Amazon EC2</p>
</div>

<div class="card">
<h3>Operating System</h3>
<p>Ubuntu 24.04 LTS</p>
</div>

<div class="card">
<h3>Web Server</h3>
<p>Nginx</p>
</div>

<div class="card">
<h3>Infrastructure</h3>
<p>Terraform</p>
</div>

<div class="card">
<h3>Programming</h3>
<p>Python Certified</p>
</div>

<div class="card">
<h3>Platform</h3>
<p>Linux & DevOps</p>
</div>

</div>

<div class="badges">

<div class="badge">AWS</div>
<div class="badge">Ubuntu</div>
<div class="badge">Terraform</div>
<div class="badge">Nginx</div>
<div class="badge">Python</div>
<div class="badge">Linux</div>
<div class="badge">DevOps</div>

</div>

<div class="status">

Deployment Status : SUCCESS

</div>

<div class="footer">

<p><strong>Region:</strong> AWS Mumbai (ap-south-1)</p>

<p><strong>Provisioned Using:</strong> Terraform + Ubuntu + Nginx + Cloud Init</p>

<p><strong>Infrastructure:</strong> EC2 • Security Group • Ubuntu • Python • DevOps</p>

<p style="margin-top:15px;">
© 2026 AWS DevOps Demonstration
</p>

</div>

</div>

</body>

</html>
HTML

systemctl restart nginx

EOF

  tags = {
    Name = "Terraform-Ubuntu-Nginx"
  }
}