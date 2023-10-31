#!/bin/bash

PROJECT_NAME="rss-agg"

# Import environment variables
export $(grep -v '^#' .env | xargs)

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [dev, prod]"
    exit 1
fi

# Check if the argument is "dev" and execute the corresponding command
if [ "$1" = "dev" ]; then
    v watch run src
elif [ "$1" = "prod" ]; then
    v src --prod -o bin/$PROJECT_NAME
    ./bin/$PROJECT_NAME
else
	echo "Invalid argument. Use 'dev' or 'prod'."
	exit 1
fi