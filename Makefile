DOMAIN_PREFIX=au-com-infoready-
APPNAME=$(DOMAIN_PREFIX)myapp
CONFSTACK=$(APPNAME)-CONF
DEVSTACK=$(APPNAME)-DEV

validate:
	aws cloudformation validate-template --template-body file://cloudformation/configuration.yml

init: validate init-create init-push

un-init:
	aws cloudformation delete-stack --stack-name $(CONFSTACK)
	git remote remove aws
	time aws cloudformation wait stack-delete-complete --stack-name $(CONFSTACK)

re-init: un-init init

init-create:
	aws cloudformation create-stack --stack-name $(CONFSTACK) \
	  --capabilities CAPABILITY_NAMED_IAM \
		--template-body file://stacks/configuration.yml \
		--parameters ParameterKey=AppName,ParameterValue=$(APPNAME)
	time aws cloudformation wait stack-create-complete --stack-name $(CONFSTACK)

init-push:
	git remote add aws \
	  `aws cloudformation list-exports | jq -r '.Exports | map(select(.Name == "$(CONFSTACK):CloneUrl")) | .[0].Value'`
	git push aws master
