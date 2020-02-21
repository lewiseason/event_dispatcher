require "event_dispatcher"

describe EventDispatcher::Dispatcher do
  let(:event1) { Event1.new }
  let(:event2) { Event2.new }

  before do
    stub_const("Notifier1", instance_double("Notifier"))
    stub_const("Notifier2", instance_double("Notifier"))
    stub_const("Notifier3", instance_double("Notifier"))

    stub_const("Event1", Class.new(EventDispatcher::Event))
    stub_const("Event2", Class.new(EventDispatcher::Event))
  end

  # TODO: Group these into contexts a bit, maybe relating to how many notifications/events are supplied.

  it "notifies a notifier when the event is raised" do
    enable_notifiers(Notifier1)
    make_dispatcher([Event1 => Notifier1])

    EventDispatcher::Dispatcher.raise(event1)

    expect(Notifier1).to have_received(:call).with(event1)
  end

  it "does nothing when no events are connected to notifiers" do
    make_dispatcher([])

    EventDispatcher::Dispatcher.raise(event1)
  end

  it "notifies multiple notifiers if specified in one #on call" do
    enable_notifiers(Notifier1, Notifier2)
    make_dispatcher(Event1 => [Notifier1, Notifier2])

    EventDispatcher::Dispatcher.raise(event1)

    expect(Notifier1).to have_received(:call).with(event1)
  end

  it "notifies multiple notifiers if the same event is specified once for each" do
    enable_notifiers(Notifier1, Notifier2)
    make_dispatcher({ Event1 => Notifier1 }, { Event1 => Notifier2 })

    EventDispatcher::Dispatcher.raise(event1)

    expect(Notifier1).to have_received(:call).with(event1)
  end

  it "triggers a notifier once even if it's specified twice" do
    enable_notifiers(Notifier1)
    make_dispatcher({ Event1 => Notifier1 }, { Event1 => Notifier1 })

    EventDispatcher::Dispatcher.raise(event1)

    expect(Notifier1).to have_received(:call).with(event1).once
  end

  it "triggers a notifier for each event raised, even if they're the same type" do
    enable_notifiers(Notifier1)
    make_dispatcher({ Event1 => Notifier1 })

    EventDispatcher::Dispatcher.raise(event1, event1)

    expect(Notifier1).to have_received(:call).with(event1).exactly(2).times
  end

  # A helper which is the equivalent to including EventDispatcher::Dispatcher,
  # then defining rules with #on.
  #
  # For example:
  #
  # class MyDispatcher
  #   include EventDispatcher::Dispatcher
  #   on Foo, Bar, notify: [Baz, Quuz]
  # end
  #
  # Is the same as:
  #
  # make_dispatcher([Foo, Bar] => [Baz, Quuz])
  #
  def make_dispatcher(*rulesets)
    rulesets = [rulesets].flatten

    stub_const("Dispatcher", Class.new do
      include EventDispatcher::Dispatcher

      rulesets.each do |ruleset|
        ruleset.each { |events, notifiers| on(*events, notify: notifiers) }
      end
    end)
  end

  def enable_notifiers(*notifiers)
    notifiers.each { |notifier_class| allow(notifier_class).to receive(:call) }
  end
end
