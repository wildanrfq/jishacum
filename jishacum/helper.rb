require "discordrb"

require_relative "config"

def fnum(num_string)
    num_string.to_s.reverse.scan(/\d{3}|.+/).join(",").reverse
end

def page_control(arr, page, error = false)
    embed = error ? Embed(nil, arr[page], 16711680) : Embed(nil, arr[page])
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Page #{page+1}/#{arr.length}")
    return embed
end

def split_message(event, message, prefix = nil, suffix = nil)
    prefix = prefix ? prefix.to_s : nil
    suffix = suffix ? suffix.to_s : nil
    if prefix && suffix
        pre, suf = prefix.length, suffix.length
        if (message.length + pre + suf) <= 2000
            return [pre + message + suf]
        else
            return message.chars.each_slice(2000-pre-suf).map(&:join).map {|s| prefix+s+suffix}.map {|s| s.gsub(event.bot.token, "[TOKEN REDACTED]")}
        end
    elsif prefix && !suffix
        pre = prefix.length
        if (message.length + pre) <= 2000
            return [pre + message]
        else
            return message.chars.each_slice(2000-pre).map(&:join).map {|s| prefix+s}.map {|s| s.gsub(event.bot.token, "[TOKEN REDACTED]")}
        end
    elsif !prefix && suffix
        suf = suffix.length
        if (message.length + suf) <= 2000
            return [message + suf]
        else
            return message.chars.each_slice(2000-suf).map(&:join).map {|s| s+suffix}.map {|s| s.gsub(event.bot.token, "[TOKEN REDACTED]")}
        end
    else
        if message.length <= 2000
            return [message]
        else
            return message.chars.each_slice(2000).map(&:join).map {|s| s.gsub(event.bot.token, "[TOKEN REDACTED]")}
        end
    end
end

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

def send_view(ev, con, com)
    ev.respond(con, false, nil, nil, nil, nil, com)
end

def r(event, text) # return function in jsc eval command
    if !text
        if ["ev<<", "ev<< ", "ev << ", "ev <<"].any? {event.message.content.include?(_1)}
            return
        else
            event.respond("nil")
            return
        end
    end
    if text.to_s.length > 2000
        JishacumPaginator.start(event, split_message(event, text.to_s))
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
        JishacumPaginator.start(event, split_message(event, text, "```rb\n", "\n```"))
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

