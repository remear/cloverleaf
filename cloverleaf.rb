require 'bunny'
require 'json'

class EventHandler
  # define a method for each event type you wish to process. return true/false

  def self.debit_failed(payload)
    true
  end

  def self.credit_succeeded(payload)
    true
  end

  def self.credit_failed(payload)
    true
  end

  # catch undefined event type methods and log a warning
  def self.method_missing(method, *args, &block)
    $stderr.puts "WARNING: #{method} handler method is not defined"
  end
end

class Cloverleaf
  Thread.new do
    conn = Bunny.new
    conn.start

    ch = conn.create_channel
    q = ch.queue("balanced_event_incoming", :durable => true)

    ch.prefetch(1)
    $stdout.puts "Waiting for messages. To exit press CTRL+C"

    q.subscribe(:ack => true, :block => true) do |delivery_info, properties, body|
      begin
        payload = JSON.parse body

        if EventHandler.send(payload['type'].gsub!(".", "_"), payload)
          ch.ack(delivery_info.delivery_tag)
        else
          raise Exception.new("Event #{payload['type']} #{payload['href']} failed to process!")
        end
      rescue Exception => e
        ch.reject(delivery_info.delivery_tag, requeue=true)
        $stdout.puts e.message
        $stdout.puts e.backtrace.inspect
      end
    end
  end
end