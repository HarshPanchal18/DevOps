resource "aws_s3_bucket" "bucket-harsh" {
  bucket = var.bucket-name
  force_destroy = true          # Allows deleting non-empty buckets
  provider = aws.east        # Use the AWS provider for us-east-1

  tags = {
    Name = "MyTerraformBucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "bucket-0" {
    provider = aws.east                        # Use the default AWS provider
    bucket = aws_s3_bucket.bucket-harsh.bucket # Reference the bucket created above
    key = "hello.txt"                          # The name of the object in the bucket
    source = "hello.txt"                       # Path to the local file to upload
    etag = filemd5("hello.txt")                # MD5 hash of the file
    content_type = "text/plain"                # MIME type of the file
}