# dec-collab
Infoready December 2018 Collab repo

This is going to be slightly more complicated because there are two important
remotes - one is github, where the sharing of the members of the Collab occurs,
and the other is AWS CodeCommit which is where the application under development
(deployed in your account) is hosted.

Keep an eye on slack and we'll work out any issues there.

## How to branch in github

origin == shared github repo hosting

origin/master - team consensus of the best code. pull request your branch onto
master.

origin/feature/x - feature "x" branch mergeable to master.

origin/alilee - personal branch for experimentation. Merge to a feature branch
before merging to master.

# Pre-requisites

AWS CREDENTIALS SETUP

In your AWS Account, under the IAM service area, create a new user.
Create the user with Programattic Access.  For now, assign them to the AWS Managed policy: "AdministratorAccess".
Obtain the "Access Key Id" and "Secret Access Key"
Then follow the below to create the profile which will be used for build and deployments. 
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

SOFTWARE ENVIRONMENT SETUP

Ensure you have virtualenv installed (if not already):
```aidl
pip install virtualenv
```
Once installed, make the virtual environment you will use for your aws stacks:
```aidl
make venv

# Then switch to that vitual environment
source venv/bin/activate
```

Then install the required software you need in your environment.  
Ensure you have your "venv" environment currnetly active prior to running this step.
Note: Certain repos work while others have conflicts.  Extend with another make entry for environments that don't work with these setups.
```aidl
# This will be all that is needed for most machines. Some issues exist for Ubuntu.
# Any new packages required are to be added to the ./requirements.txt  
make install

# For ubuntu.  Only run this if experience issue installing jq via 'make install' above
make install-ubuntu
```

The makefile has been adjusted to use the profile da-dec-collab in all aws commands.
You should now be able to run the make init command.  Enter the AWS user/secret key for AWS CodeCommit when prompted:
```aidl
make init
```