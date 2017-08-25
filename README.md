# Cross Account Microservices with CodePipeline, CodeBuild and Lambda

[![](images/Serverless-Microservices.png)][architecture]

## Deploying the serverless microservices sample application

#### 1. Pre-requisites

You will need three AWS accounts. One for the CodePipelines, one for the Bookings microservice and one for the Airmiles microservice

#### 2. Clone the sample Lambda function GitHub repository

[Clone](https://help.github.com/articles/cloning-a-repository/) the [AWS LAMBDA sample application](https://github.com/MCLDG/blg-svlss-msvc.git) GitHub repository.

From your terminal application, execute the following command:

```console
git clone https://github.com/MCLDG/blg-svlss-msvc.git
```

This creates a directory named `blg-svlss-msvc` in your current directory, which contains the code for the Serverless Microservices sample application.

#### 3. Create [AWS CodeCommit](code-commit-url) repository in Development Account

Change into the cloned directory, and edit the file single-click-cross-account-pipeline.sh

```console
vi single-click-cross-account-pipeline.sh
```

Change the following entries in lines 2-12, and save your changes:

```console
ToolsAccount=<AWS 12 digit account number for the Tools account, where the CodePipelines will be deployed>
ToolsAccountProfile=<AWS profile for the Tools account, as defined in ~/.aws/credentials>
BookingNonProdAccount=<AWS 12 digit account number for the Booking account, where the Booking microservice will be deployed>
BookingNonProdAccountProfile=<AWS profile for the Booking account, as defined in ~/.aws/credentials>
AirmilesNonProdAccount=<AWS 12 digit account number for the Airmiles account, where the Airmiles microservice will be deployed>
AirmilesNonProdAccountProfile=<AWS profile for the Airmiles account, as defined in ~/.aws/credentials>
region=<e.g. us-east-1. Must be a region where CodeCommit, CodePipeline, CodeBuild and other required services are supported)
S3_TMP_BUCKET=<name of a bucket you have access to, that can be accessed by all three accounts>
```

#### 4. Execute single-click-cross-account-pipeline.sh

From your terminal application, execute the following command:

```console
./single-click-cross-account-pipeline.sh
```

This will create stacks in all three accounts. Wait until all stacks are successfully created.

#### 5. Copy the microservice source code and push to AWS CodeCommit

In the AWS Console, in the Tools account, in the region specified in single-click-cross-account-pipeline.sh, select
the CloudFormation service and find the 'booking-pipeline' stack.

Copy the value of this stack output variable: SourceCodeCommitCloneUrlHttp
In a directory in your terminal application where you want to clone the application repository, execute the following command. 
Note that this clones an empty GIT repo for the Booking microservice, into which you'll copy the Booking source code from 
the blg-svlss-msvc.git repo (you may have to adjust the cp -R statement below if you use a different directory structure):

```console
git clone <value of the SourceCodeCommitCloneUrlHttp stack output variable>
cp -R blg-svlss-msvc/Booking/ <cloned repo directory>
cd <cloned repo directory>
git add .
git commit -m 'new'
git push
```

This will push the source code for the Booking microservice to CodeCommit, and trigger the booking CodePipeline. You can
find the CodePipeline in the AWS console by clicking the value of the PipelineUrl stack output variable in the 'booking-pipeline' stack

#### 6. Monitor deployment of the Booking microservice

In the AWS Console, in the Tools account, monitor the progress of the 'booking-pipeline' stack. Once the pipeline reaches the
DeployToTest stage, you can login to the Booking account in the AWS Console and view the status of the CloudFormation
deployment.

#### 7. Repeat steps 5 & 6 for the Airmiles microservice

Wait until the Booking CodePipeline is complete, then repeat steps 5 & 6 for the Airmiles microservice, using the stack
output values from the 'airmiles-pipeline' stack.

[code-commit-url]: https://aws.amazon.com/devops/continuous-delivery/
[code-build-url]: https://aws.amazon.com/codebuild/
[code-pipeline-url]: https://aws.amazon.com/codepipeline/
[clouformation-url]: https://aws.amazon.com/cloudformation/
[lambda-url]: https://aws.amazon.com/lambda/
