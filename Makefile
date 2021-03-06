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

create-iam-all: create-iam-role \
	create-iam-policy \
	attach-iam-role-policy

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

create-personalize-interactions-dataset-schema:
	aws personalize create-schema \
		--name $(DATASET_INTERACTIONS_SCHEMA_NAME) \
		--schema file://personalize/interactions-schema.json

delete-personalize-interactions-dataset-schema:
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
		--job-name $(INTERACTIONS_DATESET_NAME)ImportJob \
		--dataset-arn `aws personalize list-datasets | jq -r '.datasets[] | select(.name | contains("$(INTERACTIONS_DATESET_NAME)")) | .datasetArn'` \
		--data-source dataLocation=s3://$(BUCKET_NAME)/interactions.csv \
		--role-arn `aws iam list-roles | jq -r '.Roles[] | select(.RoleName | contains("$(IAM_ROLE_NAME)")) | .Arn'`

DATASET_ITEMS_SCHEMA_NAME=TestDatasetItemsSchema

create-personalize-items-dataset-schema:
	aws personalize create-schema \
		--name $(DATASET_ITEMS_SCHEMA_NAME) \
		--schema file://personalize/items-schema.json

delete-personalize-items-dataset-schema:
	aws personalize delete-schema \
		--schema-arn `aws personalize list-schemas | jq -r '.schemas[] | select(.name | contains("$(DATASET_ITEMS_SCHEMA_NAME)")) | .schemaArn'`

ITEMS_DATESET_NAME=TestItemsDataset

create-personalize-items-dataset:
	aws personalize create-dataset \
		--name $(ITEMS_DATESET_NAME) \
		--dataset-type Items \
		--dataset-group-arn `aws personalize list-dataset-groups | jq -r '.datasetGroups[] | select(.name | contains("$(DATESET_GROUP_NAME)")) | .datasetGroupArn'` \
		--schema-arn `aws personalize list-schemas | jq -r '.schemas[] | select(.name | contains("$(DATASET_ITEMS_SCHEMA_NAME)")) | .schemaArn'`

delete-personalize-items-dataset:
	aws personalize delete-dataset \
		--dataset-arn `aws personalize list-datasets | jq -r '.datasets[] | select(.name | contains("$(ITEMS_DATESET_NAME)")) | .datasetArn'`

create-personalize-items-dataset-import-job:
	aws personalize create-dataset-import-job \
		--job-name $(ITEMS_DATESET_NAME)Job \
		--dataset-arn `aws personalize list-datasets | jq -r '.datasets[] | select(.name | contains("$(ITEMS_DATESET_NAME)")) | .datasetArn'` \
		--data-source dataLocation=s3://$(BUCKET_NAME)/items.csv \
		--role-arn `aws iam list-roles | jq -r '.Roles[] | select(.RoleName | contains("$(IAM_ROLE_NAME)")) | .Arn'`

SOLUTION_NAME=TestSolution

create-personalize-solution:
	aws personalize create-solution \
		--name $(SOLUTION_NAME) \
		--dataset-group-arn `aws personalize list-dataset-groups | jq -r '.datasetGroups[] | select(.name | contains("$(DATESET_GROUP_NAME)")) | .datasetGroupArn'` \
		--perform-auto-ml

create-personalize-solution-with-sims-recipe:
	aws personalize create-solution \
		--name $(SOLUTION_NAME) \
		--dataset-group-arn `aws personalize list-dataset-groups | jq -r '.datasetGroups[] | select(.name | contains("$(DATESET_GROUP_NAME)")) | .datasetGroupArn'` \
		--recipe-arn arn:aws:personalize:::recipe/aws-sims

delete-personalize-solution:
	aws personalize delete-solution \
		--solution-arn `aws personalize list-solutions | jq -r '.solutions[] | select(.name | contains("$(SOLUTION_NAME)")) | .solutionArn'`

create-personalize-solution-version:
	aws personalize create-solution-version \
		--solution-arn `aws personalize list-solutions | jq -r '.solutions[] | select(.name | contains("$(SOLUTION_NAME)")) | .solutionArn'`

get-personalize-solution-metrics:
	aws personalize get-solution-metrics \
    	--solution-version-arn `aws personalize list-solution-versions | jq -r '.solutionVersions[-1].solutionVersionArn'`

CAMPAIGN_NAME=TestCampaign

create-personalize-campaign:
	# Since this is a test, set min-provisioned-tps to 1.
	# - ref. https://aws.amazon.com/personalize/pricing/?nc1=h_l
	#   > The actual TPS used is calculated as the average requests/second within a 5-minute window.
	#   > You pay for maximum of either the minimum provisioned TPS or the actual TPS.
	aws personalize create-campaign \
		--name $(CAMPAIGN_NAME) \
		--solution-version-arn `aws personalize list-solution-versions | jq -r '.solutionVersions[-1].solutionVersionArn'` \
		--min-provisioned-tps 1

delete-personalize-campaign:
	aws personalize delete-campaign \
		--campaign-arn `aws personalize list-campaigns | jq -r '.campaigns[] | select(.name | contains("$(CAMPAIGN_NAME)")) | .campaignArn'`

FILTER_NAME=TestFilter

create-personalize-filter:
	aws personalize create-filter \
		--name $(FILTER_NAME) \
		--dataset-group-arn `aws personalize list-dataset-groups | jq -r '.datasetGroups[] | select(.name | contains("$(DATESET_GROUP_NAME)")) | .datasetGroupArn'`  \
		--filter-expression 'EXCLUDE ItemID WHERE Items.GENRES IN ($$GENRES)'

delete-personalize-filter:
	aws personalize delete-filter \
		--filter-arn `aws personalize list-filters | jq -r '.Filters[] | select(.name | contains("$(FILTER_NAME)")) | .filterArn'` \

EXCLUDE_GENRES=\"Adventure\",\"Comedy\"

get-personalize-recommendations:
	aws personalize-runtime get-recommendations \
		--campaign-arn `aws personalize list-campaigns | jq -r '.campaigns[] | select(.name | contains("$(CAMPAIGN_NAME)")) | .campaignArn'` \
		--item-id $(ITEM_ID) \

get-personalize-recommendations-with-filter:
	aws personalize-runtime get-recommendations \
		--campaign-arn `aws personalize list-campaigns | jq -r '.campaigns[] | select(.name | contains("$(CAMPAIGN_NAME)")) | .campaignArn'` \
		--item-id $(ITEM_ID) \
		--filter-arn `aws personalize list-filters | jq -r '.Filters[] | select(.name | contains("$(FILTER_NAME)")) | .filterArn'` \
		--filter-values '{"GENRES": "$(EXCLUDE_GENRES)"}'

EVENT_TRACKER_NAME=TestEventTracker

create-personalize-event-tracker:
	aws personalize create-event-tracker \
		--name $(EVENT_TRACKER_NAME) \
		--dataset-group-arn `aws personalize list-dataset-groups | jq -r '.datasetGroups[] | select(.name | contains("$(DATESET_GROUP_NAME)")) | .datasetGroupArn'`

# TODO: Get tracking ID from aws command
TRACKING_ID=test-tracking-id
EVENT_TIMESTAMP=`date +%s`

put-personalize-event:
	aws personalize-events put-events \
        --tracking-id $(TRACKING_ID) \
        --user-id $(USER_ID) \
        --session-id session1 \
        --event-list '[{ \
            "sentAt": "$(EVENT_TIMESTAMP)", \
            "eventType": "eventTypePlaceholder", \
            "itemId": "$(ITEM_ID)" \
          }]'

create-personalize-interactions-dataset-export-job:
	aws personalize create-dataset-export-job \
		--job-name $(INTERACTIONS_DATESET_NAME)ExportJob \
		--dataset-arn `aws personalize list-datasets | jq -r '.datasets[] | select(.name | contains("$(INTERACTIONS_DATESET_NAME)")) | .datasetArn'` \
		--role-arn `aws iam list-roles | jq -r '.Roles[] | select(.RoleName | contains("$(IAM_ROLE_NAME)")) | .Arn'` \
		--ingestion-mode 'PUT' \
		--job-output '{"s3DataDestination": { "path": "s3://$(BUCKET_NAME)" }}}'

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
	aws s3 rb s3://$(BUCKET_NAME)

upload-s3-interactions-csv:
	# ref. https://docs.aws.amazon.com/personalize/latest/dg/gs-prerequisites.html#gs-upload-to-bucket
	cat data/MovieLens/ml-latest-small/ratings.csv  | cut -d "," -f 1-2,4 | sed -e 's/userId,movieId,timestamp/USER_ID,ITEM_ID,TIMESTAMP/' > tmp.csv
	aws s3 cp tmp.csv s3://$(BUCKET_NAME)/interactions.csv
	rm tmp.csv

upload-s3-items-csv:
	cat data/MovieLens/ml-latest-small/movies.csv | sed -e 's/movieId,title,genres/ITEM_ID,TITLE,GENRES/' > tmp.csv
	aws s3 cp tmp.csv s3://$(BUCKET_NAME)/items.csv
	rm tmp.csv

attach-s3-bucket-policy:
	aws s3api put-bucket-policy \
		--bucket $(BUCKET_NAME) \
		--policy file://s3/bucket-policy.json

detach-s3-bucket-policy:
	aws s3api delete-bucket-policy \
		--bucket $(BUCKET_NAME)

create-s3-all: create-s3-bucket \
	attach-s3-bucket-policy \
	upload-s3-interactions-csv \
	upload-s3-items-csv

# --------------------------------------------------
# --------------------------------------------------
# }
