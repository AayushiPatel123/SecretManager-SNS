resource "aws_cloudwatch_event_rule" "secret_accessed" {
  name        = "secret-accessed"
  description = "Trigger on secret access"

  # Define the event pattern for secret access here. You need to adjust this
  # based on the actual events emitted by Secrets Manager on access.
  event_pattern = jsonencode({
    "source" : ["aws.secretsmanager"],
    "detail-type" : ["AWS API Call via CloudTrail"],
    "detail" : {
      "eventSource" : ["secretsmanager.amazonaws.com"],
      "eventName" : ["GetSecretValue"] # Adjust based on the specific actions you want to monitor
    }
  })
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule = aws_cloudwatch_event_rule.secret_accessed.name
  arn  = aws_lambda_function.notify_on_secret_access.arn
}

resource "aws_lambda_permission" "allow_eventbridge_to_call_notify_on_secret_access" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_on_secret_access.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.secret_accessed.arn
}
