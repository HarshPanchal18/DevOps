resource "aws_s3_bucket" "bucket-harsh" {
  bucket = var.bucket-name
  force_destroy = true          # Allows deleting non-empty buckets
  provider = aws.east        # Use the AWS provider for us-east-1

  tags = {
    Name = "MyTerraformBucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "hello-txt" {
    provider = aws.east                        # Use the default AWS provider
    bucket = aws_s3_bucket.bucket-harsh.bucket # Reference the bucket created above
    key = "hello.txt"                          # The name of the object in the bucket
    source = "hello.txt"                       # Path to the local file to upload
    etag = filemd5("hello.txt")                # MD5 hash of the file
    content_type = "text/plain"                # MIME type of the file
}

locals { # Define local variables
  asset_files = fileset("assets", "**") # Get all files in the assets directory recursively.
}

resource "aws_s3_object" "assets" {
  provider = aws.east                        # Use the AWS provider for us-east-1

  for_each = { for file in local.asset_files : file => file } # Create a separate S3 object for each file in the assets directory

  key = "assets/${each.key}"                             # The name of the object in the bucket, using the file name
  bucket = aws_s3_bucket.bucket-harsh.bucket # Reference the bucket created above
  source = "assets/${each.key}"            # Path to the local file to upload
  etag = filemd5("assets/${each.key}")     # MD5 hash of the file

  content_type = lookup({ # content_type is guessed based on file extension
    ".jpg" = "image/jpeg",
    ".png" = "image/png",
    ".txt" = "text/plain",
    ".html" = "text/html"
    ".css" = "text/css",
    ".js" = "application/javascript",
    ".json" = "application/json",
    ".pdf" = "application/pdf",
    ".zip" = "application/zip",
    ".mp4" = "video/mp4",
    ".mp3" = "audio/mpeg",
    ".gif" = "image/gif",
    ".svg" = "image/svg+xml",
    ".xml" = "application/xml",
    ".csv" = "text/csv",
  },
  # substr(each.value, length(each.key) - 3, 4), # Extract the last 4 characters to match the extension
  regex("\\.[^.]+$", each.key), # get full extension like `.html`
  "application/octet-stream")                    # Default to binary (application/octet-stream) if no match

  # acl = "public-read" # Set the ACL to public-read to allow public access to the files

}