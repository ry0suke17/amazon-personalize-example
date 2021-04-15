# amazon-personalize-example

## Set up resources

```shell
# S3
make create-s3-bucket
make attach-s3-bucket-policy
make upload-s3-interactions-csv
make upload-s3-items-csv

# IAM
make create-iam-role
make create-iam-policy
make attach-iam-role-policy

# Personalize
make create-personalize-dataset-group
make create-personalize-interactions-dataset-schema
make create-personalize-items-dataset-schema
make create-personalize-interactions-dataset
make create-personalize-items-dataset
make create-personalize-interactions-dataset-import-job
make create-personalize-items-dataset-import-job
make create-personalize-solution
make create-personalize-solution-version
make create-personalize-campaign
make create-personalize-filter
```

## Get recommendations

```shell
make get-personalize-recommendations
```

## Clean up resources

```shell
# Personalize
make delete-personalize-filter
make delete-personalize-campaign
make delete-personalize-interactions-dataset
make delete-personalize-items-dataset
make delete-personalize-interactions-dataset-schema
make delete-personalize-items-dataset-schema
make delete-personalize-solution
make delete-personalize-dataset-group

# IAM
make detach-iam-role-policy 
make delete-iam-policy
make delete-iam-role

# S3
make delete-s3-bucket
```