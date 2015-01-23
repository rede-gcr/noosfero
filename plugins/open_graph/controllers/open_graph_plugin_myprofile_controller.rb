class OpenGraphPluginMyprofileController < MyProfileController

  protect 'edit_profile', :profile

  def enterprise_search
    scope = environment.enterprises.enabled.public
    profile_search scope
  end
  def community_search
    scope = environment.communities.public
    profile_search scope
  end
  def friend_search
    scope = profile.friends
    profile_search scope
  end

  def track_config
    profile.update_attributes! params[:profile_data]
    render partial: 'track_form'
  end

  protected

  def profile_search scope
    @query = params[:query]
    @profiles = scope.limit(10).order('name ASC').
      where(['name ILIKE ? OR name ILIKE ? OR identifier LIKE ?', "#{@query}%", "% #{@query}%", "#{@query}%"])
    render partial: 'profile_search', locals: {profiles: @profiles}
  end

end

