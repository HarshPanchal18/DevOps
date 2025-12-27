package main

import (
	"bytes"
	"context"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	s3manager "github.com/aws/aws-sdk-go-v2/feature/s3/manager"
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
func (bc *BucketClient) UploadObject(ctx context.Context, bucket, key string) error {
	fileBytes, err := os.ReadFile(key)
	if err != nil {
		errorLogger.Println(err)
	}

	uploader := s3manager.NewUploader(bc.client)
	output, err := uploader.Upload(ctx, &s3.PutObjectInput{
		Bucket : aws.String(bucket),
		Key    : aws.String(key),
		Body   : bytes.NewReader(fileBytes),
	})

	if err != nil {
		return err
	}

	infoLogger.Println(
		aws.ToString(output.Key),
		aws.ToString(output.ETag),
		aws.ToString((*string)(&output.ChecksumType)),
		aws.ToString((*string)(&output.ServerSideEncryption)),
	)
	return nil
}

// GetObject retrieves object contents as bytes.
func (bc *BucketClient) GetObject(ctx context.Context, bucket, key, newFile string) error {
	file, err := os.Create(newFile)
	if err != nil {
		return fmt.Errorf("create file %q: %w", newFile, err)
	}

	defer file.Close()

	downloader := s3manager.NewDownloader(bc.client)
	_, err = downloader.Download(ctx, file, &s3.GetObjectInput{Bucket: aws.String(bucket), Key: aws.String(key)})
	if err != nil {
		return fmt.Errorf("download s3://%s/%s: %w", bucket, key, err)
	}

	return nil
}

func (bc *BucketClient) DeleteObject(ctx context.Context, bucket, key string) (bool, error) {
	existed, err := bc.ExistObject(ctx, bucket, key)
	if err != nil {
		return existed, err
	}
	_, err = bc.client.DeleteObject(ctx, &s3.DeleteObjectInput{Bucket: aws.String(bucket), Key: aws.String(key)})
	if err != nil {
		return existed, err
	}

	return existed, err
}

// ListObjects returns the objects from the bucket's first page.
func (bc *BucketClient) ExistObject(ctx context.Context, bucket, key string) (bool, error) {
	objs, err := bc.client.HeadObject(ctx, &s3.HeadObjectInput{Bucket: aws.String(bucket), Key: aws.String(key)})
	if err != nil {
		return false, err
	}

	infoLogger.Printf("%s: %s", key, aws.ToString(objs.ETag))

	return true, nil
}

// ListObjects returns the objects from the bucket's first page.
func (bc *BucketClient) ListObjects(ctx context.Context, bucket string) ([]s3types.Object, error) {
	objs, err := bc.client.ListObjectsV2(ctx, &s3.ListObjectsV2Input{Bucket: aws.String(bucket)})
	if err != nil {
		return nil, err
	}

	return objs.Contents, nil
}

var infoLogger  = log.New(os.Stdout, "[INFO] ", log.Ldate|log.LstdFlags)
var errorLogger = log.New(os.Stderr, "[ERROR] ", log.Ldate|log.LstdFlags)

func main() {
	ctx := context.Background()

	/*
	awsEndpoint := os.Getenv("AWS_S3_ENDPOINT")
	awsRegion   := os.Getenv("AWS_DEFAULT_REGION")
	bucket      := os.Getenv("AWS_S3_BUCKET_NAME")
	*/
	key         := "test.txt"

	client, err := NewBucketClient(ctx, awsEndpoint, awsRegion)
	if err != nil {
		errorLogger.Println(err)
	}

	infoLogger.Println("Client is connected")

	// Upload sample file
	err = client.UploadObject(ctx, bucket, key)
	if err != nil {
		errorLogger.Println(err)
	}

	// Get object back
	err = client.GetObject(ctx, bucket, key, "testt")
	if err != nil {
		errorLogger.Println(err)
	}

	exist, err := client.ExistObject(ctx, bucket, key)
	if err != nil {
		errorLogger.Println(err)
	}
	infoLogger.Println(exist)

	// List bucket objects
	objects, err := client.ListObjects(ctx, bucket)
	if err != nil {
		errorLogger.Println(err)
	}

	infoLogger.Printf("Found %d objects", len(objects))
	for _, o := range objects {
		infoLogger.Printf("key=%s size=%d\n", aws.ToString(o.Key), o.Size)
	}

	isDeleted, err := client.DeleteObject(ctx, bucket, key)
	if isDeleted {
		infoLogger.Printf("%s is deleted from %s.", key, bucket)
	} else {
		errorLogger.Println(err)
	}

	infoLogger.Printf("Found %d objects", len(objects))
	for _, o := range objects {
		infoLogger.Printf("key=%s size=%d\n", aws.ToString(o.Key), o.Size)
	}
}