require_relative "constants"

EXTERNALS.each do |_ext| require _ext end
RELATIVES.each do |_rlt| require_relative _rlt end

include JishacumConfig
include JishacumMiddleware

raise JishacumError::InvalidOwnerID if !((JISHACUM_CONFIG["OWNER_ID"].class == Integer) && (17..20).include?(JISHACUM_CONFIG["OWNER_ID"].to_s.length))
raise JishacumError::OwnerIDNotDefined if !JISHACUM_CONFIG["OWNER_ID"] && JISHACUM_CONFIG["OWNER_IDS"].empty?
raise JishacumError::InconsistentOwnerVariables if JISHACUM_CONFIG["OWNER_ID"] && !JISHACUM_CONFIG["OWNER_IDS"].empty?

module Jishacum
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer
    using DMBlockMiddleware if JISHACUM_CONFIG["IGNORE_DMS"]
    using MessageModifierMiddleware

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
    
    uptime = {time: 0}
    actual_commands = ["jsc exit", "jsc x", "jsc r", "jsc restart", "jsc shutdown"]

    ready do |event|
        if JISHACUM_CONFIG["OWNER_ID"]
            Discordrb::API::User.resolve(event.bot.token, JISHACUM_CONFIG["OWNER_ID"]) rescue raise JishacumError::InvalidOwnerID
        elsif !JISHACUM_CONFIG["OWNER_IDS"].empty?
            JISHACUM_CONFIG["OWNER_IDS"].each do |id|
                Discordrb::API::User.resolve(event.bot.token, id) rescue raise JishacumError::InvalidOwnerID
            end
        end

        restz = File.open "jishacum/restart.json"
        data = JSON.load restz

        if data["msg"] != nil
            secs = Time.now - Time.parse(data["time"])
            secs = secs.to_s.split(".")[0]
            msg = event.bot.channel(data["ch"]).message(data["msg"])
            msg.edit("Successfully restarted #{event.bot.bot_user.name}, took `#{secs}` seconds to restart.")
            data = {
                "ch" => nil,
                "msg" => nil,
                "time" => nil
            }
            File.write("jishacum/restart.json", JSON.pretty_generate(data))
        end

        uptime["time"] = Time.at(Process.clock_gettime(Process::CLOCK_REALTIME)).to_i

        puts "#{event.bot.profile.distinct} - discordrb successfully logged in. (jishacum)"
    end

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
        global_commands = bot.commands.keys.map(&:to_s)
        message_commands = ["jsc e", "jsc eval", "jsc dbg", "jsc debug", "jsc rpt", "jsc repeat", "jsc run", "jsc exec", "jsc sh", "jsc shell"]
        commands = actual_commands + global_commands

        if ["jsc e ", "jsc eval ", "jsc e\n", "jsc eval\n", "jsc e \n", "jsc eval \n"].any? {message.content.start_with? prefix + _1}
            # usage: !jsc e <code> || e.g !jsc e 60+9 || !jsc eval "hello"

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

            break unless owner event # break if author is not bot owner
            
            if code.start_with?("```rb;") && code.end_with?(";```")
                code = code[6..-4]
            elsif code.start_with?("```ruby;") && code.end_with?(";```")
                code = code[8..-4]
            end

            begin
                if !code.include?("r event,") && !code.include?("r ev,") && !code.include?("reply event,") && !code.include?("reply ev,")
                    if code.include?(";")
                        lines = code.split(";")
                        lines[-1] = "r event, " + lines[-1]

                        code = lines.join(";")
                    else
                        code = "r event, " + code
                    end
                end

                result = eval code
                event.message.react("\u2705")
            rescue Exception => e
                event.message.react("\u274c")
    
                if !e.to_s.start_with?("Discordrb")
                    if e.methods.include?(:original_message)
                        if !e.original_message.include?("undefined method ")
                            if e.original_message.length > 4000
                                splitted = Discordrb::split_message(e.full_message)
                                splitted.each do |text|
                                    event.respond("```\n#{text}\n```")
                                end
                            else
                                event.respond("```\n#{e.class.name}: #{e.full_message.gsub("`#{e.name}'", "`#{e.name}`")}\n```")
                            end
                        else
                            event.respond("```\n#{e.original_message.split(" @should")[0]}\n```")
                        end
                    else
                        event.respond("```\n#{e.full_message}\n```")
                    end
                else
                    event.respond("```\n#{e.full_message}\n```")
                end
            end

        elsif message.content.start_with?(prefix+"jsc run ") || message.content.start_with?(prefix+"jsc run\n")
            # usage: !jsc run <code> || e.g !jsc run puts "hello"

            channel.start_typing
            code = message.content.sub(prefix+"jsc run ", "").sub(prefix+"jsc run\n", "")

            if code.start_with?("```rb\n") && code.end_with?("\n```")
                code = code[0..-4].sub("```rb\n", "")
            elsif code.start_with?("```ruby\n") && code.end_with?("\n```")
                code = code[0..-4].sub("\n```")
            end
            
            req = {
                run_request: {
                  language: "ruby",
                  version: "3.0.1",
                  code: code
                }
            }

            resp = HTTP.post("https://carc.in/run_requests", json: req)
            return event.respond("Error making request: #{resp.code} \n```json\n#{resp}\n```") if resp.code != 200
            data = resp.parse['run_request']['run']

            output = ''
            output = <<~END_OF_OUTPUT unless data['stdout']&.empty?
            ```
            #{data['stdout']}
            ```
            END_OF_OUTPUT

            output += <<~END_OF_ERROR unless data['stderr']&.empty?
            **Error:**
            ```
            #{data['stderr']}
            ```
            END_OF_ERROR

            reply event, output

        elsif message.content.start_with?(prefix+"jsc exec ")
            # usage: !jsc exec <user_id> <command_name> *args
            
            args = message.content.split(prefix+"jsc exec ")[1].split(" ")
            message = msg
            member = MemberConverter(srv, args[0])
            return "Member with `#{args[0]}` doesn't exist." if !member

            message.author = member
            message.content = prefix + args[1..-1].join(" ")

            delegate = Discordrb::Commands::CommandEvent.new(message, bot)
            r ev, bot.execute_command(args[1].to_sym, delegate, args[2..-1])

        elsif message.content.start_with?(prefix+"jsc repeat ") || message.content.start_with?(prefix+"jsc rpt ")
            # usage: !jsc repeat <number to repeat> <command name> 

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
                            if e.original_message.length > 4000
                                splitted = Discordrb::split_message(e.full_message)
                                splitted.each do |text|
                                    event.respond("```\n#{text}\n```")
                                end
                            else
                                event.respond("```\n#{e.class.name}: #{e.full_message.gsub("`#{e.name}'", "`#{e.name}`")}\n```")
                            end
                        else
                            event.respond("```\n#{e.original_message.split(" @should")[0]}\n```")
                        end
                    else
                        event.respond("```\n#{e.full_message}\n```")
                    end
                else
                    event.respond("```\n#{e.full_message}\n```")
                end
            end


        elsif message.content.start_with?(prefix + "jsc cat ")
            # usage: !jsc cat jishacum/config.rb

            file = message.content.split(prefix + "jsc cat ")[1]

            if File.exist?(file)
                if File.size(file) < 1024**2
                    r_cat ev, File.read(file)
                    event.message.react("\u2705")
                else
                    event.respond("File size can't be over 1MB.")
                end
            else
                event.respond("File `#{file}` doesn't exist.")
            end

        elsif message.content.start_with?(prefix + "jsc debug ") || message.content.start_with?(prefix + "jsc dbg ")
            # usage : !jsc dbg <command> [args]

            debug_time = (Benchmark.measure {start_debug(event)}).real.to_s
            event.respond("Debugged in #{debug_time} seconds.")

        elsif message.content.start_with?(prefix + "jsc sh ") || message.content.start_with?(prefix + "jsc shell ")
            # usage : !jsc sh echo 'hi'

            if message.content.start_with?(prefix + "jsc sh ")
                cmd = message.content.split(prefix + "jsc sh ")[1]
            else
                cmd = message.content.split(prefix + "jsc shell ")[1]
            end
            
            begin
                stdout, stderr, status = Open3.capture3(cmd)
            rescue Exception
                stdout = ""
                stderr = "command not found"
                status = 127
            end

            result = %{```bash
$ #{cmd}

```}        

            result_message = event.respond(result)

            begin
                stdout, stderr, status = Open3.capture3(cmd)
            rescue Exception
                stdout = ""
                stderr = "command not found"
                status = 127
            end
            result = %{```bash
$ #{cmd}

#{!stdout.empty? ? stdout.chomp : stderr.chomp}
                
#{status != 127 ? "> Return code: #{status.exitstatus} [PID: #{status.pid}]" : "> Return code: 127 [PID: -]"}
```}
            
            if result.length > 2000
                bin = HTTP.post("https://bin.readthedocs.fr/new", :form => {code: result[8..-4], lang: 'sh'})["location"]
                result_message.delete
                reply event, "Result's length is over 2,000 characters: <#{bin}>"
            else
                result_message.edit(result)
            end
        end
    end

    command(:jishacum, aliases: [:jsc], description: JISHACUM_HELP_DESCRIPTION ) do |event, arg|
        break unless owner event

        bot = event.bot
        mem = GetProcessMem.new
        presences_intent = bot.gateway.intents & Discordrb::INTENTS[:server_presences] > 0 ? "Presences intent is enabled" : "Presences intent is not enabled"
        members_intent = bot.gateway.intents & Discordrb::INTENTS[:server_members] > 0 ? "members intent is enabled" : "members intent is not enabled"
        if bot.shard_key
            shard_info = "The bot is sharded with #{bot.shard_key[0]} total shards"
        else
            shard_info = "The bot is not sharded"
        end
        if !arg
            desc = %{discordrb `v#{Discordrb::VERSION}`, `#{RUBY_DESCRIPTION}`

This bot is online since <t:#{uptime["time"]}:R> and #{shard_info}.
    
This bot is in `#{bot.servers.length}` servers and The bot can see `#{bot.users.length}` users.

This bot is running #{bot.event_threads.length} event thread#{bot.event_threads.length > 1 ? "s" : ""}.

This bot has #{!bot.awaits.empty? ? bot.awaits.length : "no"} registered awaits and #{!bot.voices.empty? ? bot.voices.length : "no"} voice connections.

#{presences_intent} and #{members_intent}.

This process is running on PID #{Process.pid} and used #{mem.mb.round(1)} MB of memory.
        }
            embed = Embed("jishacum v0.1", desc, JISHACUM_CONFIG["EMBED_HEX_COLOR"])
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://cdn.discordapp.com/emojis/315242245274075157.webp?size=1024")
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: bot.profile.distinct)
            embed.timestamp = Time.now.utc
            event.respond(nil, nil, embed)
        elsif ["shutdown", "exit"].include?(arg)
            reply event, "Exited."
            exit
        elsif ["r", "restart"].include?(arg)

            puts "Restarting..."
            msg = event.respond("Restarting...")

            data = {
                "ch" => event.channel.id,
                "msg" => msg.id,
                "time" => Time.now
            }

            File.write("jishacum/restart.json", JSON.pretty_generate(data))

            exec("bundle exec ruby #{JISHACUM_CONFIG["MAIN_BOT_FILE_NAME"]}")
        end
    end

    module_function :start_debug

end