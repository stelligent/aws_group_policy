require 'aws-sdk-core'

Given(/^I have the AWS access credentials$/) do
  access_key = ENV["AWS_ACCESS_KEY_ID"]
  access_key.should be
  secret_key = ENV["AWS_SECRET_ACCESS_KEY"]
  secret_key.should be

  @ec2 = Aws::EC2::Client.new(region: "us-west-2")
  @iam = Aws::IAM.new(region: "us-west-2")  
end

Then(/^I should be able to list all EC2 instances$/) do 
  begin
    @ec2.describe_instances(dry_run: true)
  rescue Aws::EC2::Errors::DryRunOperation => dry_run  
    # success
  rescue Aws::EC2::Errors::UnauthorizedOperation
    fail "UnauthorizedOperation raised"
  rescue Exception => e
    fail "Operation did not throw expected exception: #{e.message}"
  end
end

Then(/^I should not be able to create an EC2 instance$/) do 
  begin
    # this AMI ID will only work in US-West-2.
    @ec2.run_instances(dry_run: true, image_id: "ami-1b3b462b", min_count: 1, max_count: 1, instance_type: 't1.micro')
  rescue Aws::EC2::Errors::DryRunOperation => dry_run  
    fail "Operation would have succeeded in #{subnet_id}, #{dry_run.message}"
  rescue Aws::EC2::Errors::UnauthorizedOperation
    # success
  rescue Exception => e
    fail "Operation did not throw expected exception: #{e.message}"
  end
end

Then(/^I should be able to list all IAM users$/) do
  begin
    @iam.list_users
  rescue Aws::EC2::Errors::UnauthorizedOperation
    fail "UnauthorizedOperation raised"
  rescue Exception => e
    fail "Operation did not throw expected exception: #{e.message}"
  end
end

Then(/^I should not be able to create an IAM user$/) do
  begin
    @iam.create_user user_name: "test_user_should_not_exist_please_delete_me_if_found"
    fail "Was able to create user, should not have been. (btw, now you have to go delete the user manually.)"
  rescue Aws::IAM::Errors::AccessDenied
    #expected 
  rescue Exception => e
    fail "Operation did not throw expected exception: #{e.message}"
  end
end

Then(/^I should be able to manage my MFA$/) do
  @me = @iam.get_user().user
  @iam.list_mfa_devices(user_name: @me.user_name)
  mfa = @iam.create_virtual_mfa_device(virtual_mfa_device_name: "testing-virtual-mfa-delete-me").virtual_mfa_device
  # you can't fake actually attaching an MFA, unforch
  @iam.delete_virtual_mfa_device(serial_number: mfa.serial_number)
end

Then(/^I should be able to create access keys$/) do
  @key = @iam.create_access_key(user_name: @me.user_name).access_key
end

Then(/^I should be able to manage access keys$/) do
  @iam.update_access_key(user_name: @me.user_name, access_key_id: @key.access_key_id, status: "Active")
end

Then(/^I should be able to delete access keys$/) do
  @iam.delete_access_key(user_name: @me.user_name, access_key_id: @key.access_key_id)
end

