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

#pre requisites for booking
echo -e "creating pre-reqs stack for booking"
aws cloudformation deploy --stack-name ${BookingProject}-pre-reqs --template-file ToolsAcct/pre-reqs.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides ProjectName=$BookingProject NonProdAccount=$BookingNonProdAccount --profile $ToolsAccountProfile --region $region --debug
BookingS3Bucket=$(aws cloudformation describe-stacks --stack-name ${BookingProject}-pre-reqs --profile $ToolsAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`ArtifactBucket`].OutputValue' --output text)
BookingCMKArn=$(aws cloudformation describe-stacks --stack-name ${BookingProject}-pre-reqs --profile $ToolsAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`CMK`].OutputValue' --output text)
echo -e "Booking S3 artifact bucket name: $BookingS3Bucket"
echo -e "Booking CMK Arn: $BookingCMKArn"

#pre requisites for airmiles
echo -e "creating pre-reqs stack for airmiles"
aws cloudformation deploy --stack-name ${AirmilesProject}-pre-reqs --template-file ToolsAcct/pre-reqs.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides ProjectName=$AirmilesProject NonProdAccount=$AirmilesNonProdAccount --profile $ToolsAccountProfile --region $region
AirmilesS3Bucket=$(aws cloudformation describe-stacks --stack-name ${AirmilesProject}-pre-reqs --profile $ToolsAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`ArtifactBucket`].OutputValue' --output text)
AirmilesCMKArn=$(aws cloudformation describe-stacks --stack-name ${AirmilesProject}-pre-reqs --profile $ToolsAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`CMK`].OutputValue' --output text)
echo -e "Airmiles S3 artifact bucket name: $AirmilesS3Bucket"
echo -e "Airmiles CMK Arn: $AirmilesCMKArn"

#cross account roles for booking
echo -e "Creating cross-account roles in Booking Non-Prod Account"
aws cloudformation deploy --stack-name ${BookingProject}-toolsacct-codepipeline-cloudformation-role --template-file NonProdAccount/toolsacct-codepipeline-cloudformation-deployer.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides ToolsAccount=$ToolsAccount NonProdAccount=$AirmilesNonProdAccount CMKARN=$BookingCMKArn S3Bucket=$BookingS3Bucket --profile $BookingNonProdAccountProfile --region $region

BookingCloudFormationServiceRole=$(aws cloudformation describe-stacks --stack-name ${BookingProject}-toolsacct-codepipeline-cloudformation-role --profile $BookingNonProdAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`CloudFormationServiceRole`].OutputValue' --output text)
echo -e "BookingCloudFormationServiceRole: $BookingCloudFormationServiceRole"

BookingCodePipelineActionServiceRole=$(aws cloudformation describe-stacks --stack-name ${BookingProject}-toolsacct-codepipeline-cloudformation-role --profile $BookingNonProdAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`CodePipelineActionServiceRole`].OutputValue' --output text)
echo -e "BookingCodePipelineActionServiceRole: $BookingCodePipelineActionServiceRole"

BookingCustomCrossAccountServiceRole=$(aws cloudformation describe-stacks --stack-name ${BookingProject}-toolsacct-codepipeline-cloudformation-role --profile $BookingNonProdAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`CustomCrossAccountServiceRole`].OutputValue' --output text)
echo -e "BookingCustomCrossAccountServiceRole: $BookingCustomCrossAccountServiceRole"

#cross account roles for airmiles
echo -e "Creating cross-account roles in Airmiles Non-Prod Account"
aws cloudformation deploy --stack-name ${AirmilesProject}-toolsacct-codepipeline-cloudformation-role --template-file NonProdAccount/toolsacct-codepipeline-cloudformation-deployer.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides ToolsAccount=$ToolsAccount NonProdAccount=$BookingNonProdAccount CMKARN=$AirmilesCMKArn S3Bucket=$AirmilesS3Bucket --profile $AirmilesNonProdAccountProfile --region $region

AirmilesCloudFormationServiceRole=$(aws cloudformation describe-stacks --stack-name ${AirmilesProject}-toolsacct-codepipeline-cloudformation-role --profile $AirmilesNonProdAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`CloudFormationServiceRole`].OutputValue' --output text)
echo -e "AirmilesCloudFormationServiceRole: $AirmilesCloudFormationServiceRole"

AirmilesCodePipelineActionServiceRole=$(aws cloudformation describe-stacks --stack-name ${AirmilesProject}-toolsacct-codepipeline-cloudformation-role --profile $AirmilesNonProdAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`CodePipelineActionServiceRole`].OutputValue' --output text)
echo -e "AirmilesCodePipelineActionServiceRole: $AirmilesCodePipelineActionServiceRole"

AirmilesCustomCrossAccountServiceRole=$(aws cloudformation describe-stacks --stack-name ${AirmilesProject}-toolsacct-codepipeline-cloudformation-role --profile $AirmilesNonProdAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`CustomCrossAccountServiceRole`].OutputValue' --output text)
echo -e "AirmilesCustomCrossAccountServiceRole: $AirmilesCustomCrossAccountServiceRole"

#deploy custom resource to booking account
echo -e "creating custom resource stack in booking account"
cd Custom
pip install -r requirements.txt -t .
aws cloudformation package --template-file custom-lookup-exports.yaml --s3-bucket $S3_TMP_BUCKET --s3-prefix custom --output-template-file output-custom-lookup-exports.yaml --profile $BookingNonProdAccountProfile --region $region
aws cloudformation deploy --stack-name ${BookingProject}-custom --template-file output-custom-lookup-exports.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides CustomCrossAccountServiceRole=$AirmilesCustomCrossAccountServiceRole --profile $BookingNonProdAccountProfile --region $region
BookingCustomLookupExportsLambdaArn=$(aws cloudformation describe-stacks --stack-name ${BookingProject}-custom --profile $BookingNonProdAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`CustomLookupExportsLambdaArn`].OutputValue' --output text)
echo -e "BookingCustomLookupExportsLambdaArn: $BookingCustomLookupExportsLambdaArn"
cd ..

#deploy custom resource to airmiles account
echo -e "creating custom resource stack in airmiles account"
cd Custom
aws cloudformation package --template-file custom-lookup-exports.yaml --s3-bucket $S3_TMP_BUCKET --s3-prefix custom --output-template-file output-custom-lookup-exports.yaml --profile $AirmilesNonProdAccountProfile --region $region
aws cloudformation deploy --stack-name ${AirmilesProject}-custom --template-file output-custom-lookup-exports.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides CustomCrossAccountServiceRole=$BookingCustomCrossAccountServiceRole --profile $AirmilesNonProdAccountProfile --region $region
AirmilesCustomLookupExportsLambdaArn=$(aws cloudformation describe-stacks --stack-name ${AirmilesProject}-custom --profile $AirmilesNonProdAccountProfile --region $region --query 'Stacks[0].Outputs[?OutputKey==`CustomLookupExportsLambdaArn`].OutputValue' --output text)
echo -e "AirmilesCustomLookupExportsLambdaArn: $AirmilesCustomLookupExportsLambdaArn"
cd ..

#update the sam-config.json files with the Non Prod Account number. This is used in sam-booking.yaml to allow
#cross-account Lambda subscription from Lambda in Airmiles to SNS Topic in Booking
sed -i -e "s/123456789012/$AirmilesNonProdAccount/g" Booking/sam-config.json

#pipeline for booking microservice
echo -e "Creating Pipeline in Tools Account for Booking microservice"
aws cloudformation deploy --stack-name ${BookingProject}-pipeline --template-file ToolsAcct/code-pipeline.yaml --parameter-overrides ProjectName=$BookingProject CMKARN=$BookingCMKArn S3Bucket=$BookingS3Bucket NonProdCloudFormationServiceRole=$BookingCloudFormationServiceRole NonProdCodePipelineActionServiceRole=$BookingCodePipelineActionServiceRole --capabilities CAPABILITY_NAMED_IAM --profile $ToolsAccountProfile --region $region

#pipeline for airmiles microservice
echo -e "Creating Pipeline in Tools Account for Airmiles microservice"
aws cloudformation deploy --stack-name ${AirmilesProject}-pipeline --template-file ToolsAcct/code-pipeline.yaml --parameter-overrides ProjectName=$AirmilesProject CMKARN=$AirmilesCMKArn S3Bucket=$AirmilesS3Bucket NonProdCloudFormationServiceRole=$AirmilesCloudFormationServiceRole NonProdCodePipelineActionServiceRole=$AirmilesCodePipelineActionServiceRole --capabilities CAPABILITY_NAMED_IAM --profile $ToolsAccountProfile --region $region

#update the CMK permissions
echo -e "Adding Permissions to the CMK"
aws cloudformation deploy --stack-name ${BookingProject}-pre-reqs --template-file ToolsAcct/pre-reqs.yaml --parameter-overrides ProjectName=$BookingProject CodeBuildCondition=true --profile $ToolsAccountProfile --region $region
aws cloudformation deploy --stack-name ${AirmilesProject}-pre-reqs --template-file ToolsAcct/pre-reqs.yaml --parameter-overrides ProjectName=$AirmilesProject CodeBuildCondition=true --profile $ToolsAccountProfile --region $region

#echo -e "Adding Permissions to the Cross Accounts"
#aws cloudformation deploy --stack-name sample-lambda-pipeline --template-file ToolsAcct/code-pipeline.yaml --parameter-overrides CrossAccountCondition=true --capabilities CAPABILITY_NAMED_IAM --profile $ToolsAccountProfile