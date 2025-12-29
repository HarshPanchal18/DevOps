package main

import (
	"context"
	"encoding/json"
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

func (sc *SecretClient) CreateSecret(ctx context.Context, name string) (bool, error) {
	var created = false

	result, err := sc.client.CreateSecret(ctx, &secretsmanager.CreateSecretInput{Name: aws.String(name)})
	if err != nil {
		return created, err
	}

	created = true
	infoLogger.Printf("Secret '%s' is created", aws.ToString(result.Name))

	return created, nil
}

func (sc *SecretClient) PutSecretValue(ctx context.Context, name, value string) (bool, error) {
	_, err := sc.client.PutSecretValue(ctx, &secretsmanager.PutSecretValueInput{
		SecretId: aws.String(name),
		SecretString: aws.String(value),
	})
	if err != nil {
		return false, err
	}
	return true, nil
}

func (sc *SecretClient) GetSecretValue(ctx context.Context, name string) (string, error) {
	result, err := sc.client.GetSecretValue(ctx, &secretsmanager.GetSecretValueInput{SecretId: aws.String(name)})
	if err != nil {
		return "", err
	}
	return aws.ToString(result.SecretString), nil
}

func (sc *SecretClient) UpdateSecretValue(ctx context.Context, name, value string) (bool, error) {
	_, err := sc.client.UpdateSecret(ctx, &secretsmanager.UpdateSecretInput{
		SecretId: aws.String(name),
		SecretString: aws.String(value),
	})
	if err != nil {
		return false, err
	}

	infoLogger.Printf("Updated value for '%s' secret", name)

	return true, nil
}

func (sc *SecretClient) DeleteSecret(ctx context.Context, name string, force bool) (bool, error) {
	_, err := sc.client.DeleteSecret(ctx, &secretsmanager.DeleteSecretInput{
		SecretId: aws.String(name),
		ForceDeleteWithoutRecovery: aws.Bool(force),
	})
	if err != nil {
		return false, err
	}
	return true, nil
}

func (sc *SecretClient) GetSecretList(ctx context.Context) ([]secretsType.SecretListEntry, error) {
	result, err := sc.client.ListSecrets(ctx, &secretsmanager.ListSecretsInput{SortOrder: secretsType.SortOrderTypeAsc})
	if err != nil {
		return nil, err
	}
	return result.SecretList, nil
}

func (sc *SecretClient) RestoreSecret(ctx context.Context, name string) (bool, error) {
	_, err := sc.client.RestoreSecret(ctx, &secretsmanager.RestoreSecretInput{SecretId: aws.String(name)})
	if err != nil {
		return false, err
	}
	return true, nil
}

func (sc *SecretClient) IsSecretExist(ctx context.Context, name string) (bool, error) {
	result, err := sc.GetSecretValue(ctx, name)
	if err != nil {
		return false, err
	}

	return result != "", err
}

func (sc *SecretClient) PrintSecrets(ctx context.Context) {
	secrets, err := sc.GetSecretList(ctx)
	logIfErr(err)
	infoLogger.Printf("Found %d secrets", len(secrets))
	for _, secret := range secrets {
		infoLogger.Printf("key=%s, ARN=%s", aws.ToString(secret.Name), aws.ToString(secret.ARN))
	}
}

func logIfErr(err error) {
    if err != nil {
        errorLogger.Println(err)
    }
}

func main() {
	ctx := context.TODO()

	/*
	awsEndpoint := os.Getenv("AWS_ENDPOINT")
	awsRegion   := os.Getenv("AWS_DEFAULT_REGION")
	secretName  := os.Getenv("AWS_SECRET_NAME")
	*/

	client, err := NewSecretManagerClient(ctx, awsEndpoint, awsRegion)
	logIfErr(err)

	kvPairs := map[string]string{}
	kvPairs["john-doe"] = "john@123"
	kvPairs["db-name"] = "db-user"
	kvPairs["john-doe"] = "john@456"

	// JSONify key-value...
	secretInBytes, err := json.Marshal(kvPairs)
	logIfErr(err)
	secretInString := string(secretInBytes)

	secretExist, _ := client.IsSecretExist(ctx, secretName)
	infoLogger.Println("Secret exist:", secretExist)
	// logIfErr(err)
	if !secretExist {
		_, err = client.CreateSecret(ctx, secretName)
		logIfErr(err)
	}

	_, err = client.PutSecretValue(ctx, secretName, secretInString)
	logIfErr(err)

	client.PrintSecrets(ctx)

	value, err := client.GetSecretValue(ctx, secretName)
	logIfErr(err)
	infoLogger.Printf("%s:%s", secretName, value)

	forceDelete := false
	_, err = client.DeleteSecret(ctx, secretName, forceDelete)
	logIfErr(err)

	if forceDelete {
		infoLogger.Printf("Secret '%s' is deleted", secretName)
	} else {
		infoLogger.Printf("Secret '%s' will be deleted after recovery period", secretName)
	}

	client.PrintSecrets(ctx)

	restored, err := client.RestoreSecret(ctx, secretName)
	logIfErr(err)
	if restored {
		infoLogger.Printf("Secret '%s' is restored", secretName)
	}

	client.PrintSecrets(ctx)

	// kvPairs = make(map[string]string)
	kvPairs["table-name"] = "users"

	secretInBytes, err = json.Marshal(kvPairs)
	logIfErr(err)
	secretInString = string(secretInBytes)

	updated, err := client.UpdateSecretValue(ctx, secretName, secretInString)
	logIfErr(err)
	if updated {
		client.PrintSecrets(ctx)
	}

	value, err = client.GetSecretValue(ctx, secretName)
	logIfErr(err)
	infoLogger.Printf("%s:%s", secretName, value)
}