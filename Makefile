
# The idea is that a makefile will give some transparency to the magic.
#
# make -n does dry run showing commands that will be executed.
#
# The minimum command is, which you can try:
# $ make -n
#

# Isolates the application from others with the same name
DOMAIN_PREFIX=au-com-infoready-
# Fully qualified app name (used for stacks)
# APP_PREFIX prevents CONF resources named in global namespaces (ie. S3
# buckets) from colliding even if for same domain and app. Required when you
# don't want to share between developers.
# $ make -n APP_PREFIX=myprefix
# or for a specific make:
# $ make -n init APP_PREFIX=myprefix
APPNAME=$(DOMAIN_PREFIX)$(APP_PREFIX)app

# Configuration stack (repo and build pipeline)
CONFSTACK=$(APPNAME)-CONF
# persistence stack name
PERSTACK=$(APPNAME)-PER
# Shared application environment
DEVSTACK=$(APPNAME)-DEV

CLUSTER_ID=$(APPNAME)
DB_NAME='dbname'
DB_USER='admin'
DB_PASS='qaZXsw21'

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

un-init-persistence:
	aws cloudformation delete-stack --stack-name $(PERSTACK)
	time aws cloudformation wait stack-delete-complete --stack-name $(PERSTACK)

init-persistence:
	aws cloudformation create-stack --stack-name $(PERSTACK) \
		--capabilities CAPABILITY_NAMED_IAM \
		--template-body file://cloudformation/persistence.yml \
		--parameters ParameterKey=AppName,ParameterValue=$(APPNAME) \
		  ParameterKey=ClusterId,ParameterValue=$(CLUSTER_ID) \
		  ParameterKey=DatabaseName,ParameterValue=$(DB_NAME) \
		  ParameterKey=DatabaseUsername,ParameterValue=$(DB_USER) \
		  ParameterKey=DatabasePassword,ParameterValue=$(DB_PASS)
	time aws cloudformation wait stack-create-complete --stack-name $(PERSTACK)

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
