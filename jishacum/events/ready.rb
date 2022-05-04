require "discordrb"

require_relative "../errors"
require_relative "../config"

include JishacumConfig

module ReadyEvent
    extend Discordrb::EventContainer

    ready do |event|
        if JISHACUM_CONFIG["OWNER_ID"]
            Discordrb::API::User.resolve(event.bot.token, JISHACUM_CONFIG["OWNER_ID"]) rescue raise JishacumError::InvalidOwnerID
        elsif !JISHACUM_CONFIG["OWNER_IDS"].empty?
            JISHACUM_CONFIG["OWNER_IDS"].each do |id|
                Discordrb::API::User.resolve(event.bot.token, id) rescue raise JishacumError::InvalidOwnerID
            end
        end

        restz = File.open "jishacum/data/restart.json"
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
            File.write("jishacum/data/restart.json", JSON.pretty_generate(data))
        end

        File.write("jishacum/data/uptime.json", JSON.pretty_generate({"uptime" => Time.at(Process.clock_gettime(Process::CLOCK_REALTIME)).to_i}))

        puts "#{event.bot.profile.distinct} - discordrb successfully logged in. (jishacum)"

        restz.close
    end


end