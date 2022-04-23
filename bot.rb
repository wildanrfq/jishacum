require "discordrb"
require_relative "jishacum/jishacum" # import the jishacum container file

bot = Discordrb::Commands::CommandBot.new token: "OTAyOTkzMTY2MjgwNTcyOTM4.YXmf6w.jkX8__1cs9HSuryBppJXLWRvim8", prefix: "!", ignore_bots: true

bot.include! Jishacum # include the jishacum container to your bot

bot.command :hello do |event|
    event.respond("Hello, #{event.author.name}!")
end

bot.run