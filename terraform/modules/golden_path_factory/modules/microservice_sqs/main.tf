locals {
  name = "${var.service_name}-${var.environment}"
}

resource "aws_sqs_queue" "this" {
  name                        = var.queue_type == "fifo" ? "${local.name}.fifo" : local.name
  fifo_queue                  = var.queue_type == "fifo"
  content_based_deduplication = var.queue_type == "fifo"
  kms_master_key_id           = "alias/aws/sqs"

  tags = merge(var.common_tags, {
    Name        = local.name
    Environment = var.environment
    Team        = var.team_name
  })
}

resource "aws_sqs_queue" "dlq" {
  name              = "${local.name}-dlq"
  kms_master_key_id = "alias/aws/sqs"

  tags = merge(var.common_tags, {
    Name        = "${local.name}-dlq"
    Environment = var.environment
    Team        = var.team_name
  })
}

resource "aws_sqs_queue_redrive_policy" "this" {
  queue_url = aws_sqs_queue.this.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
}
