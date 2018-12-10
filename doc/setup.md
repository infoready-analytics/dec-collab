# AWS CREDENTIALS SETUP

In your AWS Account, under the IAM service area, create a new user.
Create the user with Programattic Access.  For now, assign them to the AWS
Managed policy: "AdministratorAccess".
Obtain the "Access Key Id" and "Secret Access Key"
Then follow the below to create the profile which will be used for build and
deployments.
```aidl
aws configure --profile da-dec-collab

AWS Access Key Id: <pasted from IAM>
AWS Secret Access Key: <pasted from IAM>
Default region name: ap-southeast-2
Default output format: json
```
Now create the HTTPS Git Credentials for AWS CodeCommit repo:
```aidl
1. Go to IAM/Users and scroll to HTTPS Git credentials for AWS CodeCommit
2. Generate credentials and store them off.
```

# PYTHON ENVIRONMENT SETUP

Ensure you have virtualenv installed (if not already):
```aidl
pip install virtualenv
```
Once installed, make the virtual environment you will use for your aws stacks:
```aidl
virtualenv venv

# Then switch to that virtual environment
source venv/bin/activate
```

Then install the required software you need in your environment.  
Ensure you have your "venv" environment currently active prior to running this
step.
Note: Certain repos work while others have conflicts.  Extend with another make
entry for environments that don't work with these setups.
```aidl
# This will be all that is needed for most machines. Some issues exist for Ubuntu.
# Any new packages required are to be added to the ./requirements.txt  
pip install -r requirements.txt

# JQ is packaged with some operating systems, if you can't get it from python.
# ubuntu:
sudo apt install jq
# os x:
brew install jq
```

To use your project specific profile you need to add the following to the
environment in each shell session you will be calling the aws cli from
(including from make).
```aidl
export AWS_PROFILE=da-dec-collab
# then you can supply your make commands.  
# Note: the APP_PREFIX must be lowercase and uniquely idenify your stack
make init APP_PREFIX=myprefix
```
