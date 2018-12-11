# Logical environments and branching in CodeCommit

master - corresponds to the DEV environment. Deployed on commit/push.
uat - corresponds to the UAT environment. Deployed on commit/push.
prd - corresponds to the PRD environment. Manually triggered.

I think each stack will need its own CodePipeline.
