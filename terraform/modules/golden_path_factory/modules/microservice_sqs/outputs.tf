output "queue_url" {
  value = aws_sqs_queue.this.url
}

output "dlq_url" {
  value = aws_sqs_queue.dlq.url
}
