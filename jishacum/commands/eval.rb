require "discordrb"

require_relative "../helper"
require_relative "../paginator"

module EvalCommand
    extend Discordrb::EventContainer
    include! JishacumPaginator

    message do |event|
        message = msg = event.message
        prefix = event.bot.prefix
        lp = prefix.length
        ev = event
        @event = event
        server = srv = event.server
        next if !srv && !JISHACUM_CONFIG["IGNORE_DMS"]
        author = au = event.author
        channel = ch = event.channel
        bot = event.bot
        me = event.server.bot
        ref = msg.referenced_message || nil
        drb = Discordrb
        actual_commands = ["jsc exit", "jsc x", "jsc r", "jsc restart", "jsc shutdown"]
        global_commands = bot.commands.keys.map(&:to_s)
        message_commands = ["jsc e", "jsc eval", "jsc dbg", "jsc debug", "jsc rpt", "jsc repeat", "jsc run", "jsc exec", "jsc sh", "jsc shell"]
        commands = actual_commands + global_commands

        if ["jsc e ", "jsc eval ", "jsc e\n", "jsc eval\n", "jsc e \n", "jsc eval \n"].any? {message.content.start_with? prefix + _1}
            # usage: !jsc e <code> || e.g !jsc e 60+9 || !jsc eval "hello"
            break unless owner event

            if message.content.start_with? prefix+"jsc e "
                code = message.content.split(prefix+"jsc e ")[1].gsub("\n", ";")
            elsif message.content.start_with? prefix+"jsc eval "
                code = message.content.split(prefix+"jsc eval ")[1].gsub("\n", ";")
            elsif message.content.start_with? prefix+"jsc e\n"
                code = message.content.split(prefix+"jsc e\n")[1].gsub("\n", ";")
            elsif message.content.start_with? prefix+"jsc eval\n"
                code = message.content.split(prefix+"jsc eval\n")[1].gsub("\n", ";")
            elsif message.content.start_with? prefix+"jsc e \n"
                code = message.content.split(prefix+"jsc e \n")[1].gsub("\n", ";")
            elsif message.content.start_with? prefix+"jsc eval \n"
                code = message.content.split(prefix+"jsc eval \n")[1].gsub("\n", ";")
            end
            
            if code.start_with?("```rb;") && code.end_with?(";```")
                code = code[6..-4]
            elsif code.start_with?("```ruby;") && code.end_with?(";```")
                code = code[8..-4]
            end

            begin
                if code.end_with?("end;")
                    code = code[0..-2]
                end
                
                if !code.end_with?("end")
                    if ["r ev,", "r event,", "reply ev,", "reply event,"].any? {!code.include?(_1)}
                        if code.include?(";")
                            lines = code.split(";")
                            lines[-1] = "r event, " + lines[-1]

                            code = lines.join(";")
                        else
                            code = "r event, " + code
                        end
                    end
                end

                eval code
                event.message.react("\u2705")
            rescue Exception => e
                event.message.react("\u274c")
    
                if !e.to_s.start_with?("Discordrb")
                    if e.methods.include?(:original_message)
                        if !e.original_message.include?("undefined method ")
                            if e.original_message.length > 4000
                                JishacumPaginator.start(event, split_message(event, e.original_message, "```\n", "\n```"))
                            else
                                event.respond("```\n#{e.class.name}: #{e.full_message.gsub("`#{e.name}'", "`#{e.name}`")}\n```")
                            end
                        else
                            event.respond("```\n#{e.original_message.split(" @should")[0]}\n```")
                        end
                    else
                        if e.full_message.length > 4000
                            JishacumPaginator.start(event, split_message(event, e.full_message, "```\n", "\n```"))
                        else
                            event.respond("```\n#{e.full_message}\n```")
                        end
                    end
                else
                    if e.full_message.length > 4000
                        JishacumPaginator.start(event, split_message(event, e.full_message, "```\n", "\n```"))
                    else
                        event.respond("```\n#{e.full_message}\n```")
                    end
                end
            end
        end
    end
end