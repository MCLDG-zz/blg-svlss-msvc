.PHONY: server

STACK_NAME=WebBeanstalk
TEMPLATE=web-beanstalk.yml
S3_PREFIX=web-beanstalk.zip
STORE_STACK_NAME=WebStore
TEMPLATE_STORE=store-resources-in-dynamo.yml

dependency:
	npm install
	zip -r web-beanstalk.zip *
	aws s3 cp $(S3_PREFIX) s3://$(S3_BUCKET)/$(S3_PREFIX)

deploy: dependency
	aws cloudformation deploy \
		--template-file $(shell pwd)/$(TEMPLATE) \
		--stack-name $(STACK_NAME) \
		--capabilities CAPABILITY_IAM \
		--parameter-overrides S3BucketName=$(S3_BUCKET) S3BucketKey=$(S3_PREFIX) KeyName=development \
		--region $(REGION_NAME) && \
	aws cloudformation wait stack-create-complete --stack-name $(STACK_NAME) --region $(REGION_NAME)

	aws cloudformation create-stack \
		--template-body file:////$(shell pwd)/$(TEMPLATE_STORE) \
		--stack-name $(STORE_STACK_NAME) \
		--capabilities CAPABILITY_IAM \
		--region $(REGION_NAME) \
		--parameters ParameterKey=StackName,ParameterValue=$(STACK_NAME)
	aws cloudformation wait stack-create-complete --stack-name $(STORE_STACK_NAME) --region $(REGION_NAME)

server:
	@echo "Webserver starting - navigate to http://localhost:3000"
	@node app.js 
