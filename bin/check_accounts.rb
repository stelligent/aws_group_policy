require 'aws-sdk-core'
require 'trollop'

opts = Trollop::options do
  opt :read_only_group, "name of the read only group to assign non-mfa'd users to.", required: true, type: String
  opt :full_privilege_group, "name of the full full privileged group group to assign mfa'd users to. The script will only inspect users of this group.", required: true, type: String
end

def privileged_user? iam, privileged_group, username
  result = false
  user_groups = iam.list_groups_for_user(user_name: username).groups
  user_groups.each do |group| 
    if group.group_name == privileged_group
      result = true
      break
    end
  end
  result
end


# iam doesn't actually care about region, but you need to pass one in
iam = Aws::IAM::Client.new(region: 'us-east-1')

all_users = iam.list_users.users
all_users.each do |user|
  if privileged_user? iam, opts[:full_privilege_group], user.user_name
    if iam.list_mfa_devices(user_name: user.user_name).mfa_devices.size == 0
      puts "privileged user #{user.user_name} does not have an MFA attached, moving to read only group #{opts[:read_only_group]}"
      iam.add_user_to_group user_name: user.user_name, group_name: opts[:read_only_group]
      iam.remove_user_from_group user_name: user.user_name, group_name: opts[:full_privilege_group]
    end
  end
end
