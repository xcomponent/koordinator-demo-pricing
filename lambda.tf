data "archive_file" "report_lambda" {
  type        = "zip"
  source_dir = "${path.module}/lambda/"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "report" {
  filename      = data.archive_file.report_lambda.output_path
  function_name = "DemoPricing_Report"
  role          = "arn:aws:iam::163696169398:role/S3FullAccess"
  handler       = "index.handler"
  publish       = true
  source_code_hash = data.archive_file.report_lambda.output_base64sha256

  runtime = "nodejs10.x"

  tags = {
    "com.xcomponent.label" = var.koordinator_aws_lambda_label
    "com.xcomponent.outputs.statusCode" = "String"
    "com.xcomponent.outputs.url" = "String"
    "com.xcomponent.inputs.type" = "String"
    "com.xcomponent.inputs.name" = "String"
    "com.xcomponent.inputs.id_pricing" = "String"
    "com.xcomponent.inputs.asOf" = "String"
  }
}
