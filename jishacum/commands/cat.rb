require "discordrb"
require_relative "../helper"

module CatCommand
    extend Discordrb::EventContainer

    message do |event|
        message = event.message
        prefix = event.bot.prefix

        if message.content.start_with?(prefix + "jsc cat ")
            # usage: !jsc cat jishacum/config.rb
            break unless owner event

            file = message.content.split(prefix + "jsc cat ")[1]

            if File.exist?(file)
                if File.size(file) < (1024**2)*5
                    r_cat event, File.read(file)
                    event.message.react("\u2705")
                else
                    event.respond("File size can't be over 5MB.")
                end
            else
                event.respond("File `#{file}` doesn't exist.")
            end
        end
    end
end