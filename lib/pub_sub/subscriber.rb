module PubSub
  module Subscriber
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

    def queue_name=(queue_name)
      @queue_name = queue_name
    end

    def bunny
      @bunny ||= begin
        logger.info("PubSub:Subscriber#bunny: initializing and starting new bunny instance")
        
        b = Bunny.new(bunny_config)
        b.start
        b.qos
        b
      end
    end

    def reset
      logger.info("PubSub:Subscriber#reset: unsubscribing from queue and stopping bunny")
      
      @queue.unsubscribe rescue nil
      @queue = nil
      @bunny.stop rescue nil
      @bunny = nil
    end

    # simple subsciption loop on a durable queue, automatic acks
    # creates the queue if it does not already exist
    def subscribe(&block)
      raise "queue_name must be set before calling subscribe" unless @queue_name

      logger.info("PubSub:Subscriber#subscribe: subscribing to queue - #{@queue_name}")
      begin
        @queue = bunny.queue(@queue_name, :durable => true)
        @queue.subscribe(:ack => true) do |msg|
          block.call(msg)
        end
      rescue StandardError, Timeout::Error => error
        logger.info("PubSub:Subscriber: error encountered while subscribing to #{@queue_name}, retrying - #{error}")
        sleep RETRY_WAIT
        reset
        retry
      end
    end
  end
end
