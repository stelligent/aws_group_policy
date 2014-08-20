aws_group_policy
=============

This repo contains CloudFormation templates and Ruby scripts to help manage your AWS IAM users.

An AWS IAM best practice is to require users to have multi-factor authentication devices attached to their accounts. Unfortunately, the default read-only policy doesn't allow users to attach an MFA to their account, and it's somewhat unclear what exact permissions are required to do so. 

So what ends up happening is in your quest to have secure account access, you give your users overly-broad permissions, and then that account is only password protected. 

This repo gives you the tools to avoid this anti-pattern. It contains two CloudFormation templates for creating IAM groups, and then a Ruby script that will check each user's MFA status and put them in the appopriate group.

* conf/full_privilege_group.json -- this template creates an IAM Group with full admin privleges. 
* conf/read_only_group.json -- this template creates an IAM group with read-only access, but also the ability to create and attach an MFA to their IAM account.
* conf/user.json -- this isn't required, but is a simple CloudFormation template for creating a user. If you want to use the Cucumber feature, you can use this template to create a user to test with (though you'll still need to download the credentials from the console).
* feature/ -- this directory contains a Cucumber test to ensure that the read-only policy is read-only enough, but still allows users to create and attach MFAs. 
* bin/check_accounts.rb -- this is the Ruby script that puts users into the appropriate group.
