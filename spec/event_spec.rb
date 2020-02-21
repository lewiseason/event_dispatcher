require "event_dispatcher"

describe EventDispatcher::Event do
  let(:event_class) do
    Class.new(EventDispatcher::Event) do
      attribute :name, EventDispatcher::Types::String
    end
  end

  let(:event) { event_class.new(name: "Test") }

  it "accepts attributes" do
    expect(event.name).to eq("Test")
  end
end
