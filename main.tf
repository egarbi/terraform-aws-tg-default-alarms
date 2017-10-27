variable "tg_arn_suffixes" {
  type = "list"
  description = "The list of Target Groups' ARN suffixies for what you need to add alerts"
}

variable "lb_arn" {
  description = "The ALB's ARN associated with all TGs (need to be the same)"
}

variable "sns_arn" {
  description = "SNS associated with the email, slack, push service paging your Team"
}

data "aws_lb" "main" {
  arn  = "${var.lb_arn}"
}

resource "aws_cloudwatch_metric_alarm" "target-response-time" {
  count = "${length(var.tg_arn_suffixes)}"
  alarm_name          = "${replace(var.tg_arn_suffixes[count.index],"/(targetgroup/)|(/\\w+$)/","")}-Response-Time"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions {
    LoadBalancer = "${data.aws_lb.main.arn_suffix}"
    TargetGroup  = "${var.tg_arn_suffixes[count.index]}"
  }

  alarm_description  = "Trigger an alert when response time in ${var.tg_arn_suffixes[count.index]} goes high"
  alarm_actions      = ["${var.sns_arn}"]
  ok_actions         = ["${var.sns_arn}"]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "target-unhealthy-count" {
  count = "${length(var.tg_arn_suffixes)}"
  alarm_name          = "${replace(var.tg_arn_suffixes[count.index],"/(targetgroup/)|(/\\w+$)/","")}-Unhealthy-Count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnhealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  dimensions {
    LoadBalancer = "${data.aws_lb.main.arn_suffix}"
    TargetGroup  = "${var.tg_arn_suffixes[count.index]}"
  }

  alarm_description  = "Trigger an alert when ${var.tg_arn_suffixes[count.index]} has 1 or more unhealthy hosts"
  alarm_actions      = ["${var.sns_arn}"]
  ok_actions         = ["${var.sns_arn}"]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "target-500" {
  count               = "${length(var.tg_arn_suffixes)}"
  alarm_name          = "${replace(var.tg_arn_suffixes[count.index],"/(targetgroup/)|(/\\w+$)/","")}-HTTP-5XX"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  dimensions {
    LoadBalancer = "${data.aws_lb.main.arn_suffix}"
    TargetGroup  = "${var.tg_arn_suffixes[count.index]}"
  }

  alarm_description  = "Trigger an alert when 5XX's in ${var.tg_arn_suffixes[count.index]} goes high"
  alarm_actions      = ["${var.sns_arn}"]
  ok_actions         = ["${var.sns_arn}"]
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "target-400" {
  count               = "${length(var.tg_arn_suffixes)}"
  alarm_name          = "${replace(var.tg_arn_suffixes[count.index],"/(targetgroup/)|(/\\w+$)/","")}-HTTP-4XX"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"

  dimensions {
    LoadBalancer = "${data.aws_lb.main.arn_suffix}"
    TargetGroup  = "${var.tg_arn_suffixes[count.index]}"
  }

  alarm_description  = "Trigger an alert when 4XX's in ${var.tg_arn_suffixes[count.index]} goes high"
  alarm_actions      = ["${var.sns_arn}"]
  ok_actions         = ["${var.sns_arn}"]
  treat_missing_data = "notBreaching"
}
