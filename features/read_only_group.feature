@vpc_restriction
Feature: Policies keep users restricted to a specific VPC
  As an owner of an AWS account
  I would like to start people with only only accounts until they set up an MFA
  So that my attack profile is minimized 

  Background:
    Given I have the AWS access credentials 

  Scenario: I should have read-only access to various services
    Then I should be able to list all EC2 instances
    Then I should not be able to create an EC2 instance
    Then I should be able to list all IAM users
    Then I should not be able to create an IAM user

  Scenario: My non-VPC permissions are set up correctly
    Then I should be able to manage my MFA
    Then I should be able to create access keys
    Then I should be able to manage access keys
    Then I should be able to delete access keys

