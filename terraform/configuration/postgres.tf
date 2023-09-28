resource "aws_db_instance" "poc" {
  allocated_storage           = 10
  db_name                     = "poc"
  engine                      = "postgres"
  engine_version              = "11.10"
  instance_class              = "db.t2.micro"
  manage_master_user_password = true
  username                    = "poc"
  parameter_group_name        = "default.postgres11"

  vpc_security_group_ids = [aws_security_group.poc_sg.id]
  publicly_accessible    = false
}

resource "aws_security_group" "poc_sg" {
  name        = "poc-sg"
  description = "Security group for PostgreSQL RDS instance"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}