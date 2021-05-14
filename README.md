# amazon-personalize-example

This is test for Amazon Personalize with the [MovieLens data](https://grouplens.org/datasets/movielens/).
This repository summarizes the commands for setting up and cleaning up the resources to get recommendations.

## Set up resources

```shell
# S3
make create-s3-all

# IAM
make create-iam-all

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
make get-personalize-recommendations ITEM_ID=item-id
```

## Put event

```shell
make put-personalize-event TRACKING_ID=tracking-id USER_ID=user-id ITEM_ID=item-id
```

## Clean up resources

```shell
# Personalize
make delete-personalize-filter
make delete-personalize-campaign
make delete-personalize-solution
make delete-personalize-interactions-dataset
make delete-personalize-items-dataset
make delete-personalize-interactions-dataset-schema
make delete-personalize-items-dataset-schema
make delete-personalize-dataset-group

# IAM
make detach-iam-role-policy 
make delete-iam-policy
make delete-iam-role

# S3
make delete-s3-bucket
```