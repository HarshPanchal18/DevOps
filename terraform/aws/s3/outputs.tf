output "aws_s3_bucket_name" {
  value = aws_s3_bucket.bucket-harsh.bucket
}

output "file_url" {
  value = "https://${aws_s3_bucket.bucket-harsh.bucket}.s3.amazonaws.com/hello.txt"
}

output "assets_urls" {
  value = { for file in local.asset_files : file => "https://${aws_s3_bucket.bucket-harsh.bucket}.s3.amazonaws.com/assets/${file}" }
}