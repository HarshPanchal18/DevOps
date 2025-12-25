package main

import (
	"bytes"
	"context"
	"io"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	s3types "github.com/aws/aws-sdk-go-v2/service/s3/types"
)

type BucketClient struct {
	client *s3.Client
}

// NewBucketClient constructs a BucketClient wrapping an AWS S3 client.
func NewBucketClient(ctx context.Context, endpoint, region string) (*BucketClient, error) {
	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion(region))
	if err != nil {
		return nil, err
	}

	s3client := s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.BaseEndpoint = aws.String(endpoint)
		o.UsePathStyle = true
	})

	return &BucketClient{client: s3client}, nil
}

// UploadObject uploads data to the given bucket/key. Returns the PutObject output or an error.
func (bc *BucketClient) UploadObject(ctx context.Context, bucket, key string, body io.Reader) (*s3.PutObjectOutput, error) {
	input := &s3.PutObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
		Body:   body,
	}
	return bc.client.PutObject(ctx, input)
}

// GetObject retrieves object contents as bytes.
func (bc *BucketClient) GetObject(ctx context.Context, bucket, key string) ([]byte, error) {
	out, err := bc.client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
	})
	if err != nil {
		return nil, err
	}
	defer out.Body.Close()
	return io.ReadAll(out.Body)
}

// ListObjects returns the objects from the bucket's first page.
func (bc *BucketClient) ListObjects(ctx context.Context, bucket string) ([]s3types.Object, error) {
	objs, err := bc.client.ListObjectsV2(ctx, &s3.ListObjectsV2Input{Bucket: aws.String(bucket)})
	if err != nil {
		return nil, err
	}

	return objs.Contents, nil
}

func main() {
	ctx := context.Background()

	awsEndpoint := os.Getenv("AWS_S3_ENDPOINT")
	awsRegion := os.Getenv("AWS_DEFAULT_REGION")
	bucketName := os.Getenv("AWS_S3_BUCKET_NAME")
	key := "test.txt"

	log.Println("Starting,...")

	client, err := NewBucketClient(ctx, awsEndpoint, awsRegion)
	if err != nil {
		log.Fatal(err)
	}

	log.Println(aws.ToString(client.client.Options().BaseEndpoint))
	log.Println(client.client.Options().Region)

	// Upload sample content
	_, err = client.UploadObject(ctx, bucketName, key, bytes.NewReader([]byte("Hello world!")))
	if err != nil {
		log.Fatal(err)
	}

	// Get object back
	data, err := client.GetObject(ctx, bucketName, key)
	if err != nil {
		log.Fatal(err)
	}

	log.Println(string(data))

	objects, err := client.ListObjects(ctx, bucketName)
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("Found %d objects", len(objects))
	for _, o := range objects {
		log.Printf("key=%s size=%d", aws.ToString(o.Key), o.Size)
	}
}