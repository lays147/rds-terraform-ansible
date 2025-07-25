package main

import (
	"fmt"

	"github.com/caarlos0/env/v11"
)

type Config struct {
  DBName string `env:"DB_NAME,required"`
  DBUser string `env:"DB_USER,required"`
  DBHost string `env:"DB_HOST,required"`
  DBPort int    `env:"DB_PORT" envDefault:"5432"`
  Region string `env:"AWS_REGION" envDefault:"us-east-1"`
}

func LoadConfig() (*Config, error) {
  var cfg Config
  if err := env.Parse(&cfg); err != nil {
    return nil, fmt.Errorf("failed to parse config: %w", err)
  }
  return &cfg, nil
}

func (c Config) DBUrl() string{
  return fmt.Sprintf("%s:%d", c.DBHost, c.DBPort)
}

func (c Config) DBDsn(password string) string {
  return fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s",
    c.DBHost, c.DBPort, c.DBUser, password, c.DBName)
}
