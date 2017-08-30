#!/usr/bin/env bash
ToolsAccount=123456789012
ToolsAccountProfile=blog-tools
BookingNonProdAccount=123456789012
BookingNonProdAccountProfile=blog-bookingnonprd
AirmilesNonProdAccount=123456789012
AirmilesNonProdAccountProfile=blog-airmilesnonprd
region=us-east-1
AirmilesProject=airmiles
BookingProject=booking
WebProject=web
S3_TMP_BUCKET=your-bucket-name

# lambda stack created by pipeline in booking account
echo -e "deleting lambda stack in booking account"
aws cloudformation delete-stack --stack-name ${BookingProject}-lambda --profile $BookingNonProdAccountProfile --region $region
aws cloudformation wait stack-delete-complete --stack-name ${BookingProject}-lambda --profile $BookingNonProdAccountProfile --region $region

#lambda stack created by pipeline in airmiles account
echo -e "deleting lambda stack in airmiles account"
aws cloudformation delete-stack --stack-name ${AirmilesProject}-lambda --profile $AirmilesNonProdAccountProfile --region $region
aws cloudformation wait stack-delete-complete --stack-name ${AirmilesProject}-lambda --profile $AirmilesNonProdAccountProfile --region $region

#pipeline for booking microservice
echo -e "deleting pipeline in tools account for booking microservice"
aws cloudformation delete-stack --stack-name ${BookingProject}-pipeline --profile $ToolsAccountProfile --region $region
aws cloudformation wait stack-delete-complete --stack-name ${BookingProject}-pipeline --profile $ToolsAccountProfile --region $region

#pipeline for airmiles microservice
echo -e "deleting pipeline in tools account for airmiles microservice"
aws cloudformation delete-stack --stack-name ${AirmilesProject}-pipeline --profile $ToolsAccountProfile --region $region
aws cloudformation wait stack-delete-complete --stack-name ${AirmilesProject}-pipeline --profile $ToolsAccountProfile --region $region

# custom resource to booking account
echo -e "deleting custom resource stack in booking account"
aws cloudformation delete-stack --stack-name ${BookingProject}-custom --profile $BookingNonProdAccountProfile --region $region
aws cloudformation wait stack-delete-complete --stack-name ${BookingProject}-custom --profile $BookingNonProdAccountProfile --region $region

#custom resource to airmiles account
echo -e "deleting custom resource stack in airmiles account"
aws cloudformation delete-stack --stack-name ${AirmilesProject}-custom --profile $AirmilesNonProdAccountProfile --region $region
aws cloudformation wait stack-delete-complete --stack-name ${AirmilesProject}-custom --profile $AirmilesNonProdAccountProfile --region $region

#cross account roles for booking
echo -e "deleting cross-account roles in booking Non-Prod Account"
aws cloudformation delete-stack --stack-name ${BookingProject}-toolsacct-codepipeline-cloudformation-role --profile $BookingNonProdAccountProfile --region $region
aws cloudformation wait stack-delete-complete --stack-name ${BookingProject}-toolsacct-codepipeline-cloudformation-role --profile $BookingNonProdAccountProfile --region $region

#cross account roles for airmiles
echo -e "deleting cross-account roles in airmiles Non-Prod Account"
aws cloudformation delete-stack --stack-name ${AirmilesProject}-toolsacct-codepipeline-cloudformation-role --profile $AirmilesNonProdAccountProfile --region $region
aws cloudformation wait stack-delete-complete --stack-name ${AirmilesProject}-toolsacct-codepipeline-cloudformation-role --profile $AirmilesNonProdAccountProfile --region $region

#pre requisites for booking
echo -e "deleting pre-reqs stack for booking"
aws cloudformation delete-stack --stack-name ${BookingProject}-pre-reqs --profile $ToolsAccountProfile --region $region
aws cloudformation wait stack-delete-complete --stack-name ${BookingProject}-pre-reqs --profile $ToolsAccountProfile --region $region

echo -e "deleting pre-reqs stack for airmiles"
aws cloudformation delete-stack --stack-name ${AirmilesProject}-pre-reqs --profile $ToolsAccountProfile --region $region
aws cloudformation wait stack-delete-complete --stack-name ${AirmilesProject}-pre-reqs --profile $ToolsAccountProfile --region $region

#echo -e "Adding Permissions to the Cross Accounts"
#aws cloudformation deploy --stack-name sample-lambda-pipeline --template-file ToolsAcct/code-pipeline.yaml --parameter-overrides CrossAccountCondition=true --capabilities CAPABILITY_NAMED_IAM --profile $ToolsAccountProfile