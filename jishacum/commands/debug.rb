require "discordrb"
require "benchmark"
require_relative "../helper"

module DebugCommand
    extend Discordrb::EventContainer

    def start_debug(event)
        message = event.message
        bot = event.bot
        prefix = bot.prefix
        
        if message.content.start_with?(prefix + "jsc debug ")
            args = message.content.split(prefix + "jsc debug ")[1]
            message.content = prefix + "jsc rpt 1 "+ args
            msg_event = Discordrb::Events::MessageEvent.new(message, bot)
            bot.send :raise_event, msg_event
        else
            args = message.content.split(prefix + "jsc dbg ")[1]
            message.content = prefix + "jsc rpt 1 "+ args
            msg_event = Discordrb::Events::MessageEvent.new(message, bot)
            bot.send :raise_event, msg_event
        end
    end

    message do |event|
        message = event.message
        prefix = event.bot.prefix

        if message.content.start_with?(prefix + "jsc debug ") || message.content.start_with?(prefix + "jsc dbg ")
            # usage : !jsc dbg <command> [args]

            debug_time = (Benchmark.measure {start_debug(event)}).real.to_s
            event.respond("Debugged in #{debug_time} seconds.")
        end
    end
    
    module_function :start_debug
end