resource "aws_iam_role" "environment" {
  name               = "${var.rolename}-role"
  assume_role_policy = "${file("${path.module}/policies/${var.policyfile}")}"
  description        = "${var.rolename}"
}

resource "aws_iam_role_policy_attachment" "ssm_agent" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.environment.name
}
