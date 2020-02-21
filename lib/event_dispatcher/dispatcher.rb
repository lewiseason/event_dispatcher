module EventDispatcher
  module Dispatcher
    def self.raise(*events)
      events.each do |event|
        dispatchers.each { |dispatcher| dispatcher.dispatch(event) }
      end
    end

    def self.included(base)
      dispatchers << base
      base.extend(ClassMethods)
      base.setup
    end

    def self.dispatchers
      @dispatchers ||= Set.new
    end

    module ClassMethods
      def setup
        @rules = {}
      end

      def on(*events, notify: [])
        notify = [notify].flatten

        events.each do |event|
          @rules[event] ||= Set.new
          @rules[event] += notify
        end
      end

      def dispatch(event)
        notifiers_for(event).each { |notifier| notifier.call(event) }
      end

      def notifiers_for(event)
        @rules[event.class].to_a
      end
    end
  end
end
