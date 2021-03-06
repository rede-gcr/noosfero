require_relative 'test_helper'

class TagsTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
  end

  should 'get article tags' do
    profile = fast_create(Profile)
    a = profile.articles.create(name: 'Test')
    a.tags.create! name: 'foo'

    get "/api/v1/articles/#{a.id}/tags?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ['foo'], json
  end

  should 'post article tags' do
    login_api
    profile = fast_create(Profile)
    a = profile.articles.create(name: 'Test')

    post "/api/v1/articles/#{a.id}/tags?#{params.to_query}&tags=foo"
    assert_equal 201, last_response.status
    assert_equal ['foo'], a.reload.tag_list
  end

  should 'not post article tags if not authenticated' do
    profile = fast_create(Profile)
    a = profile.articles.create(name: 'Test')

    post "/api/v1/articles/#{a.id}/tags?#{params.to_query}&tags=foo"
    assert_equal 401, last_response.status
    assert_equal [], a.reload.tag_list
  end

  should 'get environment tags' do
    person = fast_create(Person)
    person.articles.create!(:name => 'article 1', :tag_list => 'first-tag')
    person.articles.create!(:name => 'article 2', :tag_list => 'first-tag, second-tag')
    person.articles.create!(:name => 'article 3', :tag_list => 'first-tag, second-tag, third-tag')

    get '/api/v1/environment/tags'
    json = JSON.parse(last_response.body)
    assert_equal({ 'first-tag' => 3, 'second-tag' => 2, 'third-tag' => 1 }, json)
  end

  should 'get environment tags with status DEPRECATED' do
    get '/api/v1/environment/tags'
    assert_equal Api::Status::DEPRECATED, last_response.status
  end

  should 'get environment tags for path environments' do
    person = fast_create(Person)
    person.articles.create!(:name => 'article 1', :tag_list => 'first-tag')
    person.articles.create!(:name => 'article 2', :tag_list => 'first-tag, second-tag')
    person.articles.create!(:name => 'article 3', :tag_list => 'first-tag, second-tag, third-tag')

    get '/api/v1/environments/tags'
    json = JSON.parse(last_response.body)
    json.map do |tag|
      if tag['name'] == 'first-tag'
        assert_equal(3, tag['count'])
      elsif tag['name'] == 'second-tag'
        assert_equal(2, tag['count'])
      elsif tag['name'] == 'third-tag'
        assert_equal(1, tag['count'])
      end
    end
  end

  should 'get environment tags for path environments with status OK' do
    get '/api/v1/environments/tags'
    assert_equal Api::Status::OK, last_response.status
  end

  should 'get environment tags for path environments/:id path' do
    environment = fast_create(Environment)
    person = fast_create(Person, :environment_id => environment.id)
    person.articles.create!(:name => 'article 1', :tag_list => 'first-tag')
    person.articles.create!(:name => 'article 2', :tag_list => 'first-tag, second-tag')
    person.articles.create!(:name => 'article 3', :tag_list => 'first-tag, second-tag, third-tag')

    get "/api/v1/environments/#{environment.id}/tags"
    json = JSON.parse(last_response.body)
    json.map do |tag|
      if tag['name'] == 'first-tag'
        assert_equal(3, tag['count'])
      elsif tag['name'] == 'second-tag'
        assert_equal(2, tag['count'])
      elsif tag['name'] == 'third-tag'
        assert_equal(1, tag['count'])
      end
    end
  end

  should 'get environment tags for path environments/:id with status OK' do
    environment = fast_create(Environment)
    get "/api/v1/environments/#{environment.id}/tags"
    assert_equal Api::Status::OK, last_response.status
  end

end
