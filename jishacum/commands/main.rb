require "discordrb"
require "get_process_mem"

require_relative "../config"
require_relative "../helper"

include JishacumConfig

JISHACUM_HELP_DESCRIPTION = %{Jishacum base command.

Commands:
`jishacum / jsc` : Shows some informations about the bot.
`jsc shutdown / exit` : Shuts down the bot.
`jsc restart / r` : Restarts the bot.
`jsc eval / e <code>` : Evaluate a code.
`jsc run <code>` : Run a Ruby code.
`jsc exec <member_id> <command>` : Run a command with a different member.
`jsc repeat / rpt <times> <command>` : Repeat a command in the specified times.
`jsc debug / dbg <command> [*args]` : Debug a command, *args is optional in case the command needs arguments.
`jsc shell / sh <command_line>` : Run a command line in the shell.
}

module MainCommand
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    uptime = {time: 0}

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

        if data["msg"]
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

    command(:jishacum, aliases: [:jsc], description: JISHACUM_HELP_DESCRIPTION) do |event, arg|
        break unless owner event

        bot = event.bot
        mem = GetProcessMem.new
        presences_intent = bot.gateway.intents & Discordrb::INTENTS[:server_presences] > 0 ? "Presences intent is enabled" : "Presences intent is not enabled"
        members_intent = bot.gateway.intents & Discordrb::INTENTS[:server_members] > 0 ? "members intent is enabled" : "members intent is not enabled"
        if bot.shard_key
            shard_info = "this bot is sharded with `#{bot.shard_key[0]}` total shards"
        else
            shard_info = "this bot is not sharded"
        end
        if !arg
            desc = %{discordrb `v#{Discordrb::VERSION}`, `#{RUBY_DESCRIPTION}`

This bot is online since <t:#{uptime["time"]}:R> and #{shard_info}.
    
This bot is in `#{fnum(bot.servers.length)}` servers and this bot can see `#{fnum(bot.users.length)}` users.

This bot is running `#{bot.event_threads.length}` event thread#{bot.event_threads.length > 1 ? "s" : ""}.

This bot has #{!bot.awaits.empty? ? "`#{bot.awaits.length}`" : "no"} registered awaits and #{!bot.voices.empty? ? "`#{bot.voices.length}`" : "no"} voice connections.

#{presences_intent} and #{members_intent}.

This process is running on PID `#{Process.pid}` and used #{mem.mb.round(1)} MB of memory.
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
end