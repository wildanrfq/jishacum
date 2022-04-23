require "discordrb"
require_relative "config"

def owner(event)
    return JISHACUM_CONFIG["OWNER_IDS"].include?(event.author.id) || event.author.id == JISHACUM_CONFIG["OWNER_ID"]
end

def Embed(title = nil, description = nil, color = 15844367, url = nil)
    em = Discordrb::Webhooks::Embed.new
    em.title = title
    em.description = description
    em.color = color
    em.url = url
    return em
end

def r(event, text) # return function in jsc eval command
    if text == nil
        event.respond("nil")
        return
    end
    if text.to_s.length > 2000
        splitted = Discordrb::split_message(text.to_s)
        splitted.each do |final|
            event.respond(final.gsub(event.bot.token, "[TOKEN REDACTED]"))
        end
    else
        if text.class == Discordrb::Member
            event.respond(text.distinct)
        elsif text.class == Discordrb::Webhooks::Embed
            event.respond(nil, nil, text)
        elsif text.class == Discordrb::Message
            return
        else
            event.respond(text.to_s.gsub(event.bot.token, "[TOKEN REDACTED]"))
        end
    end
end

def r_cat(event, text)
    event.respond("File is empty.") if !text
    if text.to_s.length > 2000
        splitted = Discordrb::split_message(text.to_s)
        splitted.each do |final|
            event.respond("```rb\n#{final}\n```")
        end
    else
        event.respond("```rb\n#{text.to_s}\n```")
    end
end

def reply(event, content = nil, embed = nil, ping = false) # reply function 
    if ping == false
        event.send(content, false, embed, nil, false, event.message, nil)
    else
        event.send(content, false, embed, nil, nil, event.message, nil)
    end
end