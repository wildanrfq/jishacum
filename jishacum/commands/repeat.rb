require "discordrb"

require_relative "../helper"
require_relative "../middleware"
require_relative "../paginator"

include JishacumMiddleware

module RepeatCommand
    extend Discordrb::EventContainer
    include! JishacumPaginator
    using MessageModifierMiddleware

    message do |event|
        message = event.message
        prefix = event.bot.prefix
        bot = event.bot
        global_commands = event.bot.commands.keys.map(&:to_s)
        actual_commands = ["jsc exit", "jsc x", "jsc r", "jsc restart", "jsc shutdown"]
        message_commands = ["jsc e", "jsc cat", "jsc eval", "jsc dbg", "jsc debug", "jsc rpt", "jsc repeat", "jsc run", "jsc exec", "jsc sh", "jsc shell"]
        commands = actual_commands + global_commands

        if message.content.start_with?(prefix+"jsc repeat ") || message.content.start_with?(prefix+"jsc rpt ")
            # usage: !jsc repeat <number to repeat> <command name> 
            break unless owner event

            begin
                if message.content.start_with?(prefix+"jsc repeat ")
                    args = message.content.split(prefix+"jsc repeat ")[1].split(" ")
                    num, command = args[0], args[1]

                    if message_commands.include?("#{command} #{args[2]}")
                        command = "#{command} #{args[2]}"
                    end

                    return event.respond("`#{num}` is not a valid number.") if !(num.to_i.to_s == num)

                    commandargs = args[1..-1].join(" ")

                    if commands.include?(command) && actual_commands.include?(commandargs)
                        num.to_i.times do |_|
                            message.content = prefix + commandargs
                            cmd_event = Discordrb::Commands::CommandEvent.new(message, bot)
                            result = bot.execute_command(command.to_sym, cmd_event, args[2..-1])
                            result ? r(ev, result) : nil
                        end
                    elsif message_commands.include?(command)
                        num.to_i.times do |_|
                            message.content = prefix + args[1..-1].join(" ")
                            msg_event = Discordrb::Events::MessageEvent.new(message, bot)
                            bot.send :raise_event, msg_event
                        end
                    else
                        event.respond("Command `#{command}` doesn't exist.")
                    end
                else
                    args = message.content.split(prefix+"jsc rpt ")[1].split(" ")
                    num, command = args[0], args[1]

                    if message_commands.include?("#{command} #{args[2]}")
                        command = "#{command} #{args[2]}"
                    end

                    return event.respond("`#{num}` is not a valid number.") if !(num.to_i.to_s == num)

                    commandargs = args[1..-1].join(" ")

                    if commands.include?(command) && (actual_commands.include?(commandargs) || global_commands.include?(command))
                        num.to_i.times do |_|
                            message.content = prefix + commandargs
                            cmd_event = Discordrb::Commands::CommandEvent.new(message, bot)
                            bot.execute_command(command.to_sym, cmd_event, args[2..-1])
                            #r(ev, result) if result
                        end
                    elsif message_commands.include?(command)
                        num.to_i.times do |_|
                            message.content = prefix + args[1..-1].join(" ")
                            msg_event = Discordrb::Events::MessageEvent.new(message, bot)
                            bot.send :raise_event, msg_event
                        end
                    else
                        event.respond("Command `#{command}` doesn't exist.")
                    end
                end
                event.message.react("\u2705")
            rescue Exception => e
                event.message.react("\u274c")
    
                if !e.to_s.start_with?("Discordrb")
                    if e.methods.include?(:original_message)
                        if !e.original_message.include?("undefined method ")
                            if e.original_message.length > 2000
                                JishacumPaginator.start(event, split_message(event, e.original_message, "```\n", "\n```"))
                            else
                                event.respond("```\n#{e.class.name}: #{e.full_message.gsub("`#{e.name}'", "`#{e.name}`")}\n```")
                            end
                        else
                            event.respond("```\n#{e.original_message.split(" @should")[0]}\n```")
                        end
                    else
                        if e.full_message.length > 2000
                            JishacumPaginator.start(event, split_message(event, e.full_message, "```\n", "\n```"))
                        else
                            event.respond("```\n#{e.full_message}\n```")
                        end
                    end
                else
                    if e.full_message.length > 2000
                        JishacumPaginator.start(event, split_message(event, e.full_message, "```\n", "\n```"))
                    else
                        event.respond("```\n#{e.full_message}\n```")
                    end
                end
            end
        end
    end
end
