Retry
===

The `Retry` module provides a wrapper around Ruby's own `retry` keyword to
reduce the amount of boilerplate required to rerun a block of code if
an exception occurs.

Without `Retry`, attempting a block thrice might look like this:

```ruby
def fetch_data
 attempts = 0

 begin
   attempts += 1
   Net::HTTP.get('example.com', '/index.html')
 rescue
   retry if attempts < 3
 end
end

fetch_data
```

The simplest usage of `Retry` reduces the code to this:

```ruby
Retry.attempt { Net::HTTP.get('example.com', '/index.html') }
```

Usage as a Module Function
-----

`Retry` can be used directly as a module function. Its arguments are:

1. A list of exceptions to recover from. If none are provided `[StandardError]`
   is the default list.

2. The number of times to _reattempt_ the block. The default is 2. (If the
   number of retry attempts is 2, the block is attempted thrice: initially once
   and then up to two more times if the block causes an exception.) Use the
   keyword `reattempts` to specify the number of reattempts.

3. An optional time in seconds to delay between attempts. The default is `0`, meaning
   no delay occurs after an attempt. Use the keyword `wait` to specify the delay.

The following shows uses all the arguments to quickly customize `retry` behavior.

```ruby
##
# Recover from Net::HTTP::ConnectionError or SocketError exceptions. Retry twice.
##
Retry.attempt(Net::HTTP::ConnectionError, SocketError, delay: 1, reattempts: 4) do
  Net::HTTP.get('example.com', '/index.html')
end
```

The example makes 4 reattempts if either the
`Net::HTTP::ConnectionError` or `SocketError` exception occurs during the `GET`
request. A delay of 1 second occurs between each attempt.

If an exception occurs that is not in the list of named exceptions,
the code exception is raised per normal.

Usage as a Concern
-----

Since `Retry` is a module, it be readily mixed into any Ruby class and called
as an instance method.

```ruby
class WebPage
  include Retryable

  def initialize(url)
    @url = url
  end

  def fetch
    attempt(Net::HTTP::ConnectionError, SocketError, delay: 1, reattempts: 4) do
      Net::HTTP.get(@url, '/index.html')
    end
  end
end
```

Exceptions
----

If all attempts fail, `attempt` raises `Retry::RetryExhaustedError`.

An instance of `Retry::RetryExhaustedError` contais the history of all
exceptions encountered _during_ all attempts via the `exception_history` method.

```ruby
begin
   attempt(ZeroDivisionError, reattempts: 2) do
     10/0
   end
 rescue Retryable::RetryExhaustedError => e
   # e.exception_history # => [ZeroDivisionError, ZeroDivisionError, ZeroDivisionError]
end
```
