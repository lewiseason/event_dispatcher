require "event_dispatcher/version"

require "event_dispatcher/dispatcher"
require "event_dispatcher/event"
require "event_dispatcher/types"

module EventDispatcher
  def self.raise(*args)
    Dispatcher.raise(*args)
  end
end
