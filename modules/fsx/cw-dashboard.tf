# FSX 
data "template_file" "fsx_dashboard" {
  template = file("./files/fsx_dashboard.json")
  vars = {
    region       = var.region
    filesystemid = aws_fsx_windows_file_system.fsx.id
  }
}

resource "aws_cloudwatch_dashboard" "fsx" {
  dashboard_name = "${var.fsx.common_name}-monitoring-fsx-filesystem"
  dashboard_body = data.template_file.fsx_dashboard.rendered
}
