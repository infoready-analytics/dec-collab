
# The idea is that a makefile will give some transparency to the magic.
#
# make -n does dry run showing commands that will be executed.
#
# The minimum command is, which you can try:
# $ make -n
#
# However in the context of our setup we should have an APP_PREFIX (all lowercase) supplied to provide a unique variation of the stack as per below:
# $ make -n APP_PREFIX=myprefix
# or for a specific make:
# $ make -n init APP_PREFIX=myprefix
#

DOMAIN_PREFIX=au-com-infoready-
APPNAME=$(DOMAIN_PREFIX)$(APP_PREFIX)app
CONFSTACK=$(APPNAME)-CONF
DEVSTACK=$(APPNAME)-DEV

validate:
	aws cloudformation validate-template --template-body file://cloudformation/configuration.yml
	aws cloudformation validate-template --template-body file://cloudformation/application.yml
	aws cloudformation list-exports

init: validate init-create init-push

un-init:
	echo `aws cloudformation list-exports | jq -r '.Exports | map(select(.Name == "$(CONFSTACK):ArtifactStoreS3BucketName")) | .[0].Value'`
	aws s3 rm --recursive \
		`aws cloudformation list-exports | jq -r '.Exports | map(select(.Name == "$(CONFSTACK):ArtifactStoreS3BucketName")) | .[0].Value'`
	aws cloudformation delete-stack --stack-name $(CONFSTACK)
	time aws cloudformation wait stack-delete-complete --stack-name $(CONFSTACK)
	git remote remove aws

re-init: un-init init

init-create:
	aws cloudformation create-stack --stack-name $(CONFSTACK) \
		--capabilities CAPABILITY_NAMED_IAM \
		--template-body file://cloudformation/configuration.yml \
		--parameters ParameterKey=AppName,ParameterValue=$(APPNAME)
	time aws cloudformation wait stack-create-complete --stack-name $(CONFSTACK)

init-push:
	echo `aws cloudformation list-exports | jq -r '.Exports | map(select(.Name == "$(CONFSTACK):CloneUrl")) | .[0].Value'`
	git remote add aws \
		`aws cloudformation list-exports | jq -r '.Exports | map(select(.Name == "$(CONFSTACK):CloneUrl")) | .[0].Value'`
	git push --set-upstream aws HEAD:master

init-up:
	aws cloudformation update-stack --stack-name $(CONFSTACK) \
		--capabilities CAPABILITY_NAMED_IAM \
		--template-body file://cloudformation/configuration.yml \
		--parameters ParameterKey=AppName,ParameterValue=$(APPNAME)
	time aws cloudformation wait stack-update-complete --stack-name $(CONFSTACK)
