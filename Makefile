
# The idea is that a makefile will give some transparency to the magic.
#
# make -n does dry run showing commands that will be executed.
#
# The minimum command is, which you can try:
# $ make -n
#

DOMAIN_PREFIX=au-com-infoready-
APPNAME=$(DOMAIN_PREFIX)myapp
CONFSTACK=$(APPNAME)-CONF
DEVSTACK=$(APPNAME)-DEV
AWS_PROFILE=da-dec-collab

validate:
	aws cloudformation validate-template --template-body file://cloudformation/configuration.yml --profile ${AWS_PROFILE}
	aws cloudformation list-exports --profile ${AWS_PROFILE}

init: validate init-create init-push

venv:
	virtualenv venv

install:
	pip install -r requirements.txt

install-ubuntu:
	sudo apt install jq

un-init:
	echo `aws cloudformation list-exports --profile ${AWS_PROFILE} | jq -r '.Exports | map(select(.Name == "$(CONFSTACK):ArtifactStoreS3BucketName")) | .[0].Value'`
	aws s3 rm --recursive \
		`aws cloudformation list-exports --profile ${AWS_PROFILE} | jq -r '.Exports | map(select(.Name == "$(CONFSTACK):ArtifactStoreS3BucketName")) | .[0].Value'`
	aws cloudformation delete-stack --stack-name $(CONFSTACK) --profile ${AWS_PROFILE}
	time aws cloudformation wait stack-delete-complete --stack-name $(CONFSTACK) --profile ${AWS_PROFILE}
	git remote remove aws

re-init: un-init init

init-create:
	aws cloudformation create-stack --stack-name $(CONFSTACK) \
		--capabilities CAPABILITY_NAMED_IAM \
		--template-body file://cloudformation/configuration.yml \
		--parameters ParameterKey=AppName,ParameterValue=$(APPNAME)
	time aws cloudformation wait stack-create-complete --stack-name $(CONFSTACK) --profile ${AWS_PROFILE}

init-push:
	echo `aws cloudformation list-exports --profile ${AWS_PROFILE} | jq -r '.Exports | map(select(.Name == "$(CONFSTACK):CloneUrl")) | .[0].Value'`
	git remote add aws \
	  `aws cloudformation list-exports --profile ${AWS_PROFILE} | jq -r '.Exports | map(select(.Name == "$(CONFSTACK):CloneUrl")) | .[0].Value'`
	git push --set-upstream aws HEAD:master
