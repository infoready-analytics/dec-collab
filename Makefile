
# The idea is that a makefile will give some transparency to the magic.
#
# make -n does dry run showing commands that will be executed.
#
# The minimum command is, which you can try:
# $ make -n
#

DOMAIN_PREFIX=au-com-infoready-
APPNAME=$(DOMAIN_PREFIX)$(APP_PREFIX)app
CONFSTACK=$(APPNAME)-CONF
DEVSTACK=$(APPNAME)-DEV

# Validate required input parameters are set or supplied to the make file
check-param:
ifeq (${APP_PREFIX}, )
$(error APP_PREFIX is not set. It is set to: ${APP_PREFIX}.  Please supply as part of your Makefile command or set it as an environment variable)
endif

validate: check-param
	aws cloudformation validate-template --template-body file://cloudformation/configuration.yml
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
