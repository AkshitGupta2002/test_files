

# First, we will create an S3 bucket, give a unique name to your bucket. 
# Tags are not necessary, but still it is a good practice

resource "aws_s3_bucket" "mybucket" {
  bucket = "my-tf-test-bucket-2029"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Set Object Ownership to Bucket owner preferred to ensure the bucket owner 
# has control over all objects, even those uploaded by others. 
# This avoids potential access conflicts for objects uploaded by other AWS accounts.

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Just like in AWS console, while creating the AWS S3 bucket, you would unblock all the public access, same here
# setting all these to false ensures that everyone in public can access the bucket and it's policies
# if some of them are true, public access would be blocked at different levels

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# In bucket ACLs, you set the bucket ACL to public read
# This allows the users to read the contents of S3 bucket, but not modify them

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}

# S3 uses an object storage model, everything is treated as an object
# This will upload the index.html to the S3 bucket and sets the permission to public-read
# set the content type to text/html to ensure that the file is html

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "index.html"
  source = "index.html"
  acl="public-read"
  content_type = "text/html"
}

# To look your index.html as a webpage, you enable the static web hosting
# set the index doument to index.html to load the website when the link is pressed

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }
    depends_on = [aws_s3_bucket_acl.example]
}














