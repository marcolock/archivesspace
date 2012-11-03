class ArchivesSpaceService

  def self.set_up_base_permissions

    if not Repository[:repo_code => Group.GLOBAL]
      # Create the "global" repository
      Repository.unrestrict_primary_key
      begin
        Repository.create(:repo_code => Group.GLOBAL,
                          :description => "Global repository",
                          :hidden => 1)
      ensure
        Repository.restrict_primary_key
      end
    end


    if User[:username => "admin"].nil?
      User.create_from_json(JSONModel(:user).from_hash(:username => User.ADMIN_USERNAME,
                                                       :name => "Administrator"),
                            :source => "local")
      DBAuth.set_password(User.ADMIN_USERNAME, User.ADMIN_USERNAME)
    end


    created_group = nil

    global_repo = Repository[:repo_code => Group.GLOBAL]

    RequestContext.open(:repo_id => global_repo.id) do
      if Group[:group_code => Group.ADMIN_GROUP_CODE].nil?
        created_group = Group.create_from_json(JSONModel(:group).from_hash(:group_code => Group.ADMIN_GROUP_CODE,
                                                                           :description => "Administrators"))
        created_group.add_user(User[:username => User.ADMIN_USERNAME])
      end
    end


    ## Standard permissions
    Permission.define("create_repository",
                      "The ability to create new repositories",
                      :level => "global")

    Permission.define("manage_repository",
                      "The ability to manage a given repository",
                      :level => "repository")

    Permission.define("update_repository",
                      "The ability to view a given repository",
                      :level => "repository")

    Permission.define("view_repository",
                      "The ability to view a given repository",
                      :level => "repository")
  end


  set_up_base_permissions
end
