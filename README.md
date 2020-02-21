# event_dispatcher

A tiny framework for decoupling business objects.
You could probably probably use [wisper] for this purpose too.
Inspired by [a medium article].

[wisper]: https://github.com/krisleech/wisper
[a medium article]: https://medium.com/@laertis.pappas/an-event-driven-approach-to-process-business-use-cases-in-ruby-201321214968

## Usage

Let's say you have a Rails application and you want to notify some external service when you call a particular controller action.
You have a `User` model, and when they suspend their subscription, you want to notify your payment processor so that they stop processing the recurring payment.

You can imagine a tightly-coupled version of this would put all of the relevant business logic in the controller.
Let's make an attempt at coming up with something better.

```ruby
class SubscriptionsController < ApplicationController
  respond_to :json

  def suspend
    @user = User.find(params[:user_id])

    if @user.subscription_active?
      @user.suspend_subscription!
      PaymentProcessor::CancelSubscription.call(@user)

      render status: :accepted
    else
      render status: :bad_request, json: {
        error: I18n.t("errors.no_active_subscription")
      }
    end
  end
end
```

You might put your notification inside the controller, maybe with `perform_later`, or maybe you extract the whole suspend process into a service class.

But now you want to email the customer too, so:

```ruby
# <snip>
@user.suspend_subscription!
PaymentProcessor::CancelSubscription.call(@user)
SubscriptionMailer.cancellation(@user).deliver
```

Again, this isn't so bad - especially if you do these operations in the background.
You can see though that it would be easy to tightly couple many different actions in your action.

---

Try this on for size:

```ruby
class CancelSubscription
  # Make an API call or push an event into a queue or whatever.
  def self.call(event)
    user = User.find(event.user_id)
    puts "Hello from CancelSubscription"
  end
end

class SendCancellationEmail
  # Send an email, push notification, or whatever.
  def self.call(event)
    user = User.find(event.user_id)
    puts "Hello from SendCancellationEmail"
  end
end

module Events
  class SubscriptionCancelled < EventDispatcher::Event
    attribute :user_id, EventDispatcher::Types::Integer
  end

  class Dispatcher
    include EventDispatcher

    on SubscriptionCancelled, notify: [CancelSubscription, SendCancellationEmail]
    # on Event1, Event2, notify: Notifier
  end
end
```

Then, instead of triggering both events in your controller/service object, simply:

```ruby
EventDispatcher.raise(Events::SubscriptionCancelled.new(user_id: @user.id))
# => Hello from CancelSubscription
# => Hello from SendCancellationEmail
```

It's a good idea to have a module to contain your events and dispatcher for each business context.
First, it means you can see all the events and notifiers for each part of your domain.
Secondly, it should avoid having autoload difficulties.
I haven't run into any yet, but in the above example if `EventDispatcher.raise` was called before the interpreter knew about `Events::Dispatcher` the notifiers would not be called.

## To Do

* [ ] come up with a good pattern for processing some or all notifications in the background; this will likely be a responsibility of the notifier itself, but it would be useful to provide an example.
* [ ] organise and improve tests; there are some, but they could do with being organised more logically

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lewiseason/event_dispatcher.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
