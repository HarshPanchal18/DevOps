package main

import (
	"context"
	"io"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func main() {
	context := context.Background()

	bucketName := os.Getenv("AWS_S3_BUCKET_NAME")
	awsEndpoint := os.Getenv("AWS_S3_ENDPOINT")
	awsRegion := os.Getenv("AWS_DEFAULT_REGION")

	client := getClient(context, awsEndpoint, awsRegion)

	log.Println(client.Options().Region)
	log.Println(*client.Options().BaseEndpoint)

	listObjects(*client, context, bucketName)
	getObject(*client, context, bucketName)

}

// Create an AWS S3 service client
func getClient(context context.Context, endpoint string, region string) *s3.Client {
	config, err := config.LoadDefaultConfig(context,config.WithRegion(region))
	if err != nil {
		log.Fatal(err)
	}

	return s3.NewFromConfig(config, func(o *s3.Options) {
		o.BaseEndpoint = aws.String(endpoint)
		o.UsePathStyle = true
	})
}

func getObject(client s3.Client, context context.Context, bucketName string) {
	output, err := client.GetObject(context, &s3.GetObjectInput{
		Bucket: aws.String(bucketName),
		Key: aws.String("go.mod"),
	})

	if err != nil {
		log.Fatal(err)
	}

	bytes, err := io.ReadAll(output.Body)

	if err != nil {
		log.Fatal(err)
	}

	log.Println(string(bytes))

}

func listObjects(client s3.Client, context context.Context, bucketName string) {
	output, err := client.ListObjectsV2(context, &s3.ListObjectsV2Input {
		Bucket: aws.String(bucketName),
	})

	log.Println(output.KeyCount)

	if err != nil {
		log.Fatal(err)
	}

	log.Println("First page results:")
	for _, object := range output.Contents {
		log.Printf("key=%s size=%d", aws.ToString(object.Key), object.Size)
	}
}