module PubSub
  module Publisher
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

    def transactional=(transactional)
      @transactional=transactional
    end

    def bunny
      @bunny ||= begin
        logger.info("PubSub:Publisher#bunny: initializing and starting new bunny instance")
        
        b = Bunny.new(bunny_config)
        b.start
        
        if(@transactional)
          logger.info("PubSub:Publisher#bunny: publisher is transactional, calling tx_select")
          b.tx_select
        end

        b
      end
    end

    def publish(msg, exchange_name, routing_key)      
      begin

        begin
          exchange = bunny.exchange(exchange_name, :type => :topic, :durable => true)
        rescue StandardError, Timeout::Error => error
          logger.info("PubSub:Publisher#publish: resetting and reconnecting to #{exchange_name}, because - #{error}")
          sleep RETRY_WAIT
          reset
          retry
        end

        exchange.publish(msg, :key => routing_key, :persistent => true)

        if(@transactional)
          logger.debug("PubSub:Publisher#bunny: publisher is transactional, calling tx_commit")
          bunny.tx_commit
        end

      rescue StandardError, Timeout::Error => error
        logger.info("PubSub:Publisher#publish: error encountered while publishing to #{exchange_name} with routing_key #{routing_key}, retrying - #{error}")
        sleep RETRY_WAIT
        reset
        retry
      end
    end

    def reset
      logger.info("PubSub:Publisher#reset: stopping bunny")

      @bunny.stop rescue nil
      @bunny = nil
    end
  end
end
