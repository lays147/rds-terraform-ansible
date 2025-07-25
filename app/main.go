package main

import (
	"context"
	"database/sql"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/rds/auth"
	_ "github.com/lib/pq"
)

func handler(ctx context.Context) error {
  log.Println("Starting RDS IAM Authentication Lambda function")
	var cfg, err = LoadConfig()
	if err != nil {
		log.Fatalf("failed to load configuration: %v", err)
	}

	awsConfig, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Fatalf("aws configuration error: %v", err)
	}
  log.Println("AWS configuration loaded successfully")

	authenticationToken, err := auth.BuildAuthToken(
		ctx, cfg.DBUrl(), cfg.Region, cfg.DBUser, awsConfig.Credentials)
	if err != nil {
		log.Fatalf("failed to create authentication token: %v", err)
	}
  log.Println("Authentication token created successfully")

	db, err := sql.Open("postgres", cfg.DBDsn(authenticationToken))
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
  log.Println("Connected to the database successfully")

	err = db.Ping()
	if err != nil {
		log.Fatalf("failed to ping database: %v", err)
	}
  log.Println("Database connection is healthy")
	return nil
}

func main() {
	lambda.Start(handler)
}
