module PubSub
  module FanoutPublisher
    include BunnyConfig

    RETRY_WAIT = 5

    def logger=(logger)
      @logger = logger
    end

    def logger
      @logger ||= begin
        logger = Logger.new(STDOUT)
        logger.level = Logger::WARN
        logger
      end
    end

    def bunny
      @bunny ||= begin
        logger.info("PubSub:FanoutPublisher#bunny: initializing and starting new bunny instance")
        
        b = Bunny.new(bunny_config)
        b.start
        b
      end
    end

    def publish(msg, exchange_name)      
      begin

        begin
          exchange = bunny.exchange(exchange_name, :type => :fanout, :durable => true)
        rescue StandardError, Timeout::Error => error
          logger.info("PubSub:FanoutPublisher#publish: resetting and reconnecting to #{exchange_name}, because - #{error}")
          sleep RETRY_WAIT
          reset
          retry
        end

        # non-persistent to a fanout exchange
        exchange.publish(msg)

      rescue StandardError, Timeout::Error => error
        logger.info("PubSub:FanoutPublisher#publish: error encountered while publishing to #{exchange_name} with routing_key #{routing_key}, retrying - #{error}")
        sleep RETRY_WAIT
        reset
        retry
      end
    end

    def reset
      logger.info("PubSub:FanoutPublisher#reset: stopping bunny")

      @bunny.stop rescue nil
      @bunny = nil
    end
  end
end
