package main

import (
	"context"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	secretsType "github.com/aws/aws-sdk-go-v2/service/secretsmanager/types"
)

type SecretClient struct {
	client *secretsmanager.Client
}

var infoLogger  = log.New(os.Stdout, "[INFO] ", log.Ldate|log.LstdFlags)
var errorLogger = log.New(os.Stderr, "[ERROR] ", log.Ldate|log.LstdFlags)

func NewSecretManagerClient(ctx context.Context, endpoint, region string) (*SecretClient, error) {
	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion(region))
	if err != nil {
		return nil, err
	}

	secretClient := secretsmanager.NewFromConfig(cfg, func(o *secretsmanager.Options) {
		o.BaseEndpoint = &endpoint
	})

	return &SecretClient{client: secretClient}, nil
}

func (sc *SecretClient) CreateKV(ctx context.Context, key, value string) (bool, error) {
	var created = false
	// value = "{\"" + key + "\":\"" + value + "\"}"

	result, err := sc.client.CreateSecret(ctx, &secretsmanager.CreateSecretInput{
		Name: aws.String(key),
		SecretString: aws.String(value),
	})
	if err != nil {
		return created, err
	}

	created = true
	infoLogger.Println("Secret '", aws.ToString(result.Name), "' is created")
	return created, nil
}

func (sc *SecretClient) GetSecret(ctx context.Context, key string) (string, error) {
	result, err := sc.client.GetSecretValue(ctx, &secretsmanager.GetSecretValueInput{SecretId: aws.String(key)})
	if err != nil {
		return "", err
	}
	return aws.ToString(result.SecretString), nil
}

func (sc *SecretClient) DeleteSecret(ctx context.Context, key string, force bool) (bool, error) {
	var deleted = false

	result, err := sc.client.DeleteSecret(ctx, &secretsmanager.DeleteSecretInput{
		SecretId: aws.String(key),
		ForceDeleteWithoutRecovery: aws.Bool(force),
	})
	if err != nil { return deleted, err }

	deleted = true
	infoLogger.Println("Secret '", aws.ToString(result.Name), "' is deleted")
	return deleted, nil
}

func (sc *SecretClient) ListSecret(ctx context.Context) ([]secretsType.SecretListEntry, error) {
	result, err := sc.client.ListSecrets(ctx, &secretsmanager.ListSecretsInput{SortOrder: secretsType.SortOrderTypeAsc})
	if err != nil {
		return nil, err
	}
	return result.SecretList, nil
}

func main() {
	ctx := context.TODO()
	secretKey := "username"
	secretValue := "john-doe"

	client, err := NewSecretManagerClient(ctx, awsEndpoint, awsRegion)
	if err != nil {
		errorLogger.Println(err)
	}

	_, err = client.CreateKV(ctx, secretKey, secretValue)
	if err != nil {
		errorLogger.Println(err)
	}

	secrets, err := client.ListSecret(ctx)
	if err != nil {
		errorLogger.Println(err)
	}
	infoLogger.Printf("Found %d secrets", len(secrets))
	for _, secret := range secrets {
		infoLogger.Printf("key=%s, ARN=%s", aws.ToString(secret.Name), aws.ToString(secret.ARN))
	}

	secret, err := client.GetSecret(ctx, secretKey)
	if err != nil {
		errorLogger.Println(err)
	}
	infoLogger.Println(secret)

	_, err = client.DeleteSecret(ctx, secretKey, true)
	if err != nil {
		errorLogger.Println(err)
	}

	// infoLogger.Printf("Found %d secrets", len(secrets))
	// for _, secret := range secrets {
	// 	infoLogger.Printf("key=%s, ARN=%s", aws.ToString(secret.Name), aws.ToString(secret.ARN))
	// }
}