require_relative "types"
require "dry-struct"

module EventDispatcher
  class Event < Dry::Struct
    include EventDispatcher::Types
  end
end
