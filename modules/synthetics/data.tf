data "aws_caller_identity" "current" {}

data "archive_file" "synthetics" {
  type        = "zip"
  output_path = "${path.module}/files/synthetics.zip"
  source_dir  = "${path.module}/synthetics"
}


data "template_file" "synthetics" {
  template = "${file("${path.module}/templates/pageLoadBlueprint.py")}"
  vars = {
    health_check_url = "${var.health_check_url}"
  }
}

resource "local_file" "synthetics" {
  content = data.template_file.synthetics.rendered
  filename = "${path.module}/synthetics/pageLoadBlueprint.py"
}
