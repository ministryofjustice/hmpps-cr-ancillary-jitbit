resource "aws_iam_role" "synthetics" {
  name               = "${var.common_name}-synthetics-role"
  assume_role_policy = file("${path.module}/templates/trust.json")
}

resource "aws_iam_policy" "synthetics" {
  name   = "${var.common_name}-synthetics-policy"
  policy = file("${path.module}/templates/synthetics.json")
}

resource "aws_iam_role_policy_attachment" "synthetics" {
  role       = aws_iam_role.synthetics.name
  policy_arn = aws_iam_policy.synthetics.arn
}
