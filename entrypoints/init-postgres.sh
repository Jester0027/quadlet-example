#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "postgres" <<-EOSQL
	CREATE USER keycloak WITH ENCRYPTED PASSWORD '$POSTGRES_KEYCLOAK_PASSWORD';
	CREATE DATABASE keycloak;
	GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
	\c keycloak postgres
	GRANT ALL ON SCHEMA public TO keycloak;
EOSQL
