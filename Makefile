# AWS IAM {
# --------------------------------------------------
# --------------------------------------------------

IAM_ROLE_NAME=PersonalizeExampleRole

create-iam-role:
	aws iam create-role \
		--role-name $(IAM_ROLE_NAME) \
		--assume-role-policy-document file://iam/role.json

delete-iam-role:
	aws iam delete-role \
    	--role-name $(IAM_ROLE_NAME)

IAM_PERSONALIZE_POLICY_NAME=PersonalizeExamplePolicy
IAM_S3_POLICY_NAME=S3ExamplePolicy

create-iam-policy:
	aws iam create-policy \
		--policy-name $(IAM_PERSONALIZE_POLICY_NAME) \
		--policy-document file://iam/personalize-policy.json
	aws iam create-policy \
		--policy-name $(IAM_S3_POLICY_NAME) \
		--policy-document file://iam/s3-policy.json

delete-iam-policy:
	aws iam delete-policy \
		--policy-arn `aws iam list-policies --scope Local | jq -r '.Policies[] | select(.PolicyName | contains("$(IAM_PERSONALIZE_POLICY_NAME)")) | .Arn'`
	aws iam delete-policy \
		--policy-arn `aws iam list-policies --scope Local | jq -r '.Policies[] | select(.PolicyName | contains("$(IAM_S3_POLICY_NAME)")) | .Arn'`

attach-iam-role-policy:
	aws iam attach-role-policy \
    	--role-name $(IAM_ROLE_NAME) \
    	--policy-arn `aws iam list-policies --scope Local | jq -r '.Policies[] | select(.PolicyName | contains("$(IAM_PERSONALIZE_POLICY_NAME)")) | .Arn'`
	aws iam attach-role-policy \
    	--role-name $(IAM_ROLE_NAME) \
    	--policy-arn `aws iam list-policies --scope Local | jq -r '.Policies[] | select(.PolicyName | contains("$(IAM_S3_POLICY_NAME)")) | .Arn'`

detach-iam-role-policy:
	aws iam detach-role-policy \
    	--role-name $(IAM_ROLE_NAME) \
    	--policy-arn `aws iam list-policies --scope Local | jq -r '.Policies[] | select(.PolicyName | contains("$(IAM_PERSONALIZE_POLICY_NAME)")) | .Arn'`
	aws iam detach-role-policy \
    	--role-name $(IAM_ROLE_NAME) \
    	--policy-arn `aws iam list-policies --scope Local | jq -r '.Policies[] | select(.PolicyName | contains("$(IAM_S3_POLICY_NAME)")) | .Arn'`

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

INTERACTIONS_DATESET_NAME=TestInteractionsDataset

create-personalize-interactions-dataset:
	aws personalize create-dataset \
		--name $(INTERACTIONS_DATESET_NAME) \
		--dataset-type Interactions \
		--dataset-group-arn `aws personalize list-dataset-groups | jq -r '.datasetGroups[] | select(.name | contains("$(DATESET_GROUP_NAME)")) | .datasetGroupArn'` \
		--schema-arn `aws personalize list-schemas | jq -r '.schemas[] | select(.name | contains("$(DATASET_INTERACTIONS_SCHEMA_NAME)")) | .schemaArn'`

delete-personalize-interactions-dataset:
	aws personalize delete-dataset \
		--dataset-arn `aws personalize list-datasets | jq -r '.datasets[] | select(.name | contains("$(INTERACTIONS_DATESET_NAME)")) | .datasetArn'`

create-personalize-interactions-dataset-import-job:
	aws personalize create-dataset-import-job \
		--job-name $(INTERACTIONS_DATESET_NAME)Job-`openssl rand -base64 12 | fold -w 10 | head -1` \
		--dataset-arn `aws personalize list-datasets | jq -r '.datasets[] | select(.name | contains("$(INTERACTIONS_DATESET_NAME)")) | .datasetArn'` \
		--data-source dataLocation=s3://$(BUCKET_NAME)/interactions.csv \
		--role-arn `aws iam list-roles | jq -r '.Roles[] | select(.RoleName | contains("$(IAM_ROLE_NAME)")) | .Arn'`

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

upload-s3-csv:
	# ref. https://docs.aws.amazon.com/personalize/latest/dg/gs-prerequisites.html#gs-upload-to-bucket
	cat data/MovieLens/ml-latest-small/ratings.csv  | cut -d "," -f 1-2,4 | sed -e 's/userId,movieId,timestamp/USER_ID,ITEM_ID,TIMESTAMP/' > interactions.csv
	aws s3 cp interactions.csv s3://$(BUCKET_NAME)/interactions.csv
	rm interactions.csv

attach-s3-bucket-policy:
	aws s3api put-bucket-policy \
		--bucket $(BUCKET_NAME) \
		--policy file://s3/bucket-policy.json

detach-s3-bucket-policy:
	aws s3api delete-bucket-policy \
		--bucket $(BUCKET_NAME)

# --------------------------------------------------
# --------------------------------------------------
# }
