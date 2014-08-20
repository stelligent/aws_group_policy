# aws_group_policy

This repo contains CloudFormation templates and Ruby scripts to help manage your AWS IAM users.

###description
=============
An AWS IAM best practice is to require users to have multi-factor authentication devices attached to their accounts. Unfortunately, the default read-only policy doesn't allow users to attach an MFA to their account, and it's somewhat unclear what exact permissions are required to do so. 

So what ends up happening is in your quest to have secure account access, you give your users overly-broad permissions, and then that account is only password protected. 

This repo gives you the tools to avoid this anti-pattern. It contains two CloudFormation templates for creating IAM groups, and then a Ruby script that will check each user's MFA status and put them in the appopriate group.

###contents
========
* **conf/full_privilege_group.json** -- this CloudFormation template creates an IAM Group with full admin privleges. 
* **conf/read_only_group.json** -- this CloudFormation template creates an IAM group with read-only access, but also the ability to create and attach an MFA to their IAM account.
* **conf/user.json** -- this isn't required, but is a simple CloudFormation template for creating a user. If you want to use the Cucumber feature, you can use this template to create a user to test with (though you'll still need to download the credentials from the console).
* **features/** -- this directory contains a Cucumber test to ensure that the read-only policy is read-only enough, but still allows users to create and attach MFAs. 
* **bin/check_accounts.rb** -- this is the Ruby script that puts users into the appropriate group.

###usage
=====
To use this script, you'll need to create the two IAM Groups, and then look up their group names. Assign your desired users into either of the groups. Run the script with the names punched in and it'll figure out the rest.

Assuming you have git, the AWS CLI, and Ruby installed...

    git clone https://github.com/stelligent/aws_group_policy.git aws_group_policy
    cd aws_group_policy
    aws cloudformation create-stack --stack-name "readonly-group" --template-body file://./aws_group_policy/conf/read_only_group.json --capabilities="CAPABILITY_IAM" --region 
    aws cloudformation create-stack --stack-name "admin-group" --template-body file://.//conf/full_privilege_group.json --capabilities="CAPABILITY_IAM" 

Then go to [the AWS IAM console](https://console.aws.amazon.com/iam) and look up your group names. They'll have some CloudFormation randomness appended to the end. Then, assign your users to either of those accounts. The script will only manipulate users in the specified groups, so if you have users that you want to be left alone (service users, users with specific permissions, etc) just don't put them into either group. 

Once your users are assigned, run this script, substituting the names for your group names:

    ruby bin/check_accounts.rb -r ReadOnlyGroup -f AdminGroup

You should see output like this:

    read-only user JeanLucPicard has an MFA attached, moving to full-privileged group AdminGroup
    privileged user WesleyCrusher does not have an MFA attached, moving to read only group ReadOnlyGroup

    
###running the tests
====
If you want to see the cucumber tests run, you'll need to manually create an IAM user and assign it to the read-only group. (there's a template in /conf that will set this all up for you).  You'll need to log into the console and grab its API keys, though.

    aws cloudformation create-stack --stack-name "test-read-only-user" --template-body file://./conf/user.json --capabilities="CAPABILITY_IAM" --parameters ParameterKey="group",ParameterValue="ReadOnlyGroup"
    export AWS_ACCESS_KEY_ID=ABCDEFGHIJKLMNOPQRSTUVWXYZ
    export AWS_SECRET_ACCESS_KEY=abcdefghijklmnop1234567890
    cucumber 
