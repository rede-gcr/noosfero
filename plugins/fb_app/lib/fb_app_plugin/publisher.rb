require 'net/http'

class FbAppPlugin::Publisher < OpenGraphPlugin::Publisher

  Actions = FbAppPlugin.open_graph_config[:actions]
  Objects = FbAppPlugin.open_graph_config[:objects]

  UpdateDelay = 1.day

  def initialize attributes = {}
    super
    self.actions = Actions
    self.objects = Objects
  end

  def scrape object_data_url
    params = {id: object_data_url, scrape: true, method: 'post'}
    url = "http://graph.facebook.com?#{params.to_query}"
    Net::HTTP.get URI.parse(url)
  end

  def publish actor, story_defs, object_data_url
    auth = actor.fb_app_auth
    return if auth.blank? or auth.expired?

    print_debug "fb_app: Auth found and valid" if debug? actor

    action = self.actions[story_defs[:action]]
    object_type = self.objects[story_defs[:object_type]]
    raise "Invalid action or object. Story: #{story_defs.inspect}; actions: #{self.actions.inspect}; object: #{self.objects.inspect}" if action.blank? or object_type.blank?

    print_debug "fb_app: action #{action}, object_type #{object_type}" if debug? actor

    # always update the object to expire facebook cache
    scrape object_data_url

    activity_params = {actor_id: actor.id, action: action, object_type: object_type, object_data_url: object_data_url}
    activity = OpenGraphPlugin::Activity.where(activity_params).first
    # only scrape recent objects to avoid multiple publications
    return if activity and activity.created_at <= (Time.now + UpdateDelay)

    print_debug "fb_app: no recent publication found, making new" if debug? actor

    namespace = FbAppPlugin.open_graph_config[:namespace]
    params = {object_type => object_data_url}
    params['fb:explicitly_shared'] = 'true' unless story_defs[:tracker]
    me = FbGraph::User.me auth.access_token
    me.og_action! "#{namespace}:#{action}", params

    activity = OpenGraphPlugin::Activity.create! activity_params
  end

  protected

  def context
    :fb_app
  end
  def debug? actor=nil
    FbAppPlugin.test_user? actor
  end

end
