require 'ki'

NP_API_KEY = 'api_key'
NP_SECRET = 'secret'

module Ki
  module Helpers
    def read_file path
      File.read(File.join(Util.root, path))
    end

    def url
      uri = "localhost:3000"
      "http://#{uri}/"
    end

    def other_developer_count
      foo = haml("%span.badge #{User.count}")
      bar = haml("%span.badge #{Storage.count}")
      "#{foo} developers storing #{bar} resources"
    end
  end

  class Model
    respond_to :json

    def before_all
      ensure_authorization
    end

    private

    def ensure_authorization
      if params[NP_API_KEY].nil? || params[NP_SECRET].nil?
        raise 'not authorized. required params missing'
      end

      h = { NP_API_KEY => params[NP_API_KEY], NP_SECRET => params[NP_SECRET]}
      u = User.find(h)
      unless @req.post? && self.class == User
        if u.empty?
          raise 'not authorized'
        end
      end
      params.delete(NP_SECRET) if !required_attributes.include? NP_SECRET.to_sym
    end
  end
end

class User < Ki::Model
  include Ki::EMail

  requires NP_API_KEY.to_sym, NP_SECRET.to_sym
  forbid :delete, :update
  unique NP_API_KEY.to_sym

  def before_create
    raise 'invalid email format' unless valid_mail?(params[NP_API_KEY])
    now = Time.now.to_i
    params[NP_SECRET] = now.to_s
    params['created_at'] = now
  end

  def after_create
    user = User.find(params)
    really_send2 'no-reply@northpole.ro', params[NP_API_KEY],
      'northpole.ro - your api key and secret', "api_key: #{user[0]['api_key']}\nsecret: #{user[0]['secret']}\n\nHappy coding,\nnorthpole.ro"
  end
end

class Storage < Ki::Model
  requires NP_API_KEY.to_sym
end

class Shell < Ki::Site
end

class Ruby < Ki::Site
end

class Java < Ki::Site
end

User.find_or_create(NP_API_KEY => 'guest@northpole.ro', NP_SECRET => 'guest')
