generate-interactions-data:
	cat data/MovieLens/ml-latest-small/ratings.csv  | cut -d "," -f 1-2,4

# AWS IAM {
# --------------------------------------------------
# --------------------------------------------------

IAM_POLICY_NAME=PersonalizeExamplePolicy

create-iam-policy:
	aws iam create-policy \
		--policy-name $(IAM_POLICY_NAME) \
		--policy-document file://iam/policy.json

delete-iam-policy:
	aws iam delete-policy \
		--policy-arn `aws iam list-policies --scope Local | jq -r '.Policies[] | select(.PolicyName | contains("$(IAM_POLICY_NAME)")) | .Arn'`

# --------------------------------------------------
# --------------------------------------------------
# }



# AWS Personalize {
# --------------------------------------------------
# --------------------------------------------------

DATESET_GROUP_NAME=TestDatasetGroup

create-personalize-dataset-group:
	aws personalize create-dataset-group \
		--name $(DATESET_GROUP_NAME)

delete-personalize-dataset-group:
	aws personalize delete-dataset-group \
		--dataset-group-arn `aws personalize list-dataset-groups | jq -r '.datasetGroups[] | select(.name | contains("$(DATESET_GROUP_NAME)")) | .datasetGroupArn'`

DATASET_INTERACTIONS_SCHEMA_NAME=TestDatasetInteractionsSchema

create-personalize-dataset-schema:
	aws personalize create-schema \
		--name $(DATASET_INTERACTIONS_SCHEMA_NAME) \
		--schema file://personalize/interactions-schema.json

delete-personalize-dataset-schema:
	aws personalize delete-schema \
		--schema-arn `aws personalize list-schemas | jq -r '.schemas[] | select(.name | contains("$(DATASET_INTERACTIONS_SCHEMA_NAME)")) | .schemaArn'`

INTERACTIONS_DATESET_NAME=TestInterractionsDataset

create-personalize-interactions-dataset:
	aws personalize create-dataset \
		--name $(INTERACTIONS_DATESET_NAME) \
		--dataset-type Interactions \
		--dataset-group-arn `aws personalize list-dataset-groups | jq -r '.datasetGroups[] | select(.name | contains("$(DATESET_GROUP_NAME)")) | .datasetGroupArn'` \
		--schema-arn `aws personalize list-schemas | jq -r '.schemas[] | select(.name | contains("$(DATASET_INTERACTIONS_SCHEMA_NAME)")) | .schemaArn'`

delete-personalize-interactions-dataset:
	aws personalize delete-dataset \
		--dataset-arn `aws personalize list-datasets | jq -r '.datasets[] | select(.name | contains("TestInterractionsDataset")) | .datasetArn'`

# --------------------------------------------------
# --------------------------------------------------
# }



# AWS S3 {
# --------------------------------------------------
# --------------------------------------------------

BUCKET_NAME=test-personalize-data2

create-s3-bucket:
	aws s3 mb s3://$(BUCKET_NAME)

delete-s3-bucket:
	aws s3 rm s3://$(BUCKET_NAME) --recursive

# --------------------------------------------------
# --------------------------------------------------
# }
