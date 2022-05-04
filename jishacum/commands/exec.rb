require "discordrb"
require_relative "../middleware"
require_relative "../helper"

include JishacumMiddleware

module ExecCommand
    extend Discordrb::EventContainer
    using MessageModifierMiddleware

    message do |event|
        message = event.message
        prefix = event.bot.prefix

        if message.content.start_with?(prefix+"jsc exec ")
            # usage: !jsc exec <user_id> <command_name> *args
            break unless owner event
            
            args = message.content.split(prefix+"jsc exec ")[1].split(" ")
            message = msg
            member = MemberConverter(srv, args[0])
            return "Member with ID `#{args[0]}` doesn't exist." if !member

            message.author = member
            message.content = prefix + args[1..-1].join(" ")

            delegate = Discordrb::Commands::CommandEvent.new(message, bot)
            r ev, bot.execute_command(args[1].to_sym, delegate, args[2..-1])
        end
    end
end