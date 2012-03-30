module PubSub
  module BunnyConfig
    def bunny_config
      defaults = { 
        :host => 'localhost',
        :port => 5672,
        :user => 'guest',
        :pass => 'guest',

        :spec => '09',
        :heartbeat => 60
      }
      defined?(BUNNY_CONFIG) ? defaults.merge(BUNNY_CONFIG) : defaults
    end
  end
end