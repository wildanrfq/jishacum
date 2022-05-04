require "discordrb"
require_relative "helper"

module JishacumPaginator
    extend Discordrb::EventContainer
    
    LIVE_PAGINATORS = {}

    def page_control(arr, page)
        embed = Embed(nil, arr[page])
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Page #{page+1}/#{arr.length}")
        return embed
    end

    def start(event, arr)
        view = Discordrb::Components::View.new do |v|
            v.row do |r|
                r.button(style: 2, emoji: "\u23ee", custom_id: "first#{event.message.id}", disabled: true)
                r.button(style: 2, emoji: "\u25c0", custom_id: "prev#{event.message.id}", disabled: true)
                r.button(style: 4, emoji: "\u{1F6D1}", custom_id: "stop#{event.message.id}")
                r.button(style: 2, emoji: "\u25b6", custom_id: "next#{event.message.id}")
                r.button(style: 2, emoji: "\u23ed", custom_id: "last#{event.message.id}")
            end
        end
        LIVE_PAGINATORS[event.message.id] = {author: event.user.id, arr: arr, page: 0, deferred: false}
        event.send_embed('', page_control(arr, 0), nil, false, nil, nil, view)
    end

    button do |event|
        data = {}
        id = event.custom_id

        LIVE_PAGINATORS.each do |k, v|
            if id.end_with? k.to_s
                data = v
                break
            end
        end

        next unless !data.empty?

        if event.user.id != data[:author]
            event.respond(content: "This button can be used only by #{event.server.member(data[:author]).distinct}!", tts: nil, embeds: nil, allowed_mentions: nil, flags: 0, ephemeral: true)
            next
        end
        
        begin
            event.defer_update
        rescue; end
        
        if id.start_with?("first")
            view = Discordrb::Components::View.new do |v|
                v.row do |r|
                    r.button(style: 2, emoji: "\u23ee", custom_id: "first#{event.message.id}", disabled: true)
                    r.button(style: 2, emoji: "\u25c0", custom_id: "prev#{event.message.id}", disabled: true)
                    r.button(style: 4, emoji: "\u{1F6D1}", custom_id: "stop#{event.message.id}")
                    r.button(style: 2, emoji: "\u25b6", custom_id: "next#{event.message.id}")
                    r.button(style: 2, emoji: "\u23ed", custom_id: "last#{event.message.id}")
                end
            end

            event.edit_response(content: nil,embeds: [page_control(data[:arr], 0)], allowed_mentions: nil, components: view)  rescue nil
            LIVE_PAGINATORS[event.message.id] = {author: event.user.id, arr: data[:arr], deferred: true, page: 0,}
        elsif id.start_with?("prev")
            dis = data[:page] == 0 ? true : false
            view = Discordrb::Components::View.new do |v|
                v.row do |r|
                    r.button(style: 2, emoji: "\u23ee", custom_id: "first#{event.message.id}", disabled: dis)
                    r.button(style: 2, emoji: "\u25c0", custom_id: "prev#{event.message.id}", disabled: dis)
                    r.button(style: 4, emoji: "\u{1F6D1}", custom_id: "stop#{event.message.id}")
                    r.button(style: 2, emoji: "\u25b6", custom_id: "next#{event.message.id}")
                    r.button(style: 2, emoji: "\u23ed", custom_id: "last#{event.message.id}")
                end
            end

            event.edit_response(content: nil,embeds: [page_control(data[:arr], data[:page]-1)], allowed_mentions: nil, components: view) rescue nil
            LIVE_PAGINATORS[event.message.id] = {author: event.user.id, arr: data[:arr], deferred: true, page: data[:page]-1}
        elsif id.start_with?("next")
            dis = data[:page]+1 == data[:arr].length-1 ? true : false
            view = Discordrb::Components::View.new do |v|
                v.row do |r|
                    r.button(style: 2, emoji: "\u23ee", custom_id: "first#{event.message.id}")
                    r.button(style: 2, emoji: "\u25c0", custom_id: "prev#{event.message.id}")
                    r.button(style: 4, emoji: "\u{1F6D1}", custom_id: "stop#{event.message.id}")
                    r.button(style: 2, emoji: "\u25b6", custom_id: "next#{event.message.id}", disabled: dis)
                    r.button(style: 2, emoji: "\u23ed", custom_id: "last#{event.message.id}", disabled: dis)
                end
            end

            event.edit_response(content: nil,embeds: [page_control(data[:arr], data[:page]+1)], allowed_mentions: nil, components: view) rescue nil
            LIVE_PAGINATORS[event.message.id] = {author: event.user.id, arr: data[:arr], deferred: true, page: data[:page]+1}
        elsif id.start_with?("last")
            view = Discordrb::Components::View.new do |v|
                v.row do |r|
                    r.button(style: 2, emoji: "\u23ee", custom_id: "first#{event.message.id}")
                    r.button(style: 2, emoji: "\u25c0", custom_id: "prev#{event.message.id}")
                    r.button(style: 4, emoji: "\u{1F6D1}", custom_id: "stop#{event.message.id}")
                    r.button(style: 2, emoji: "\u25b6", custom_id: "next#{event.message.id}", disabled: true)
                    r.button(style: 2, emoji: "\u23ed", custom_id: "last#{event.message.id}", disabled: true)
                end
            end
            
            event.edit_response(content: nil,embeds: [page_control(data[:arr], data[:arr].length-1)], allowed_mentions: nil, components: view) rescue nil
            LIVE_PAGINATORS[event.message.id] = {author: event.user.id, arr: data[:arr], deferred: true, page: data[:arr].length-1}
        elsif id.start_with?("stop")
            event.channel.message(event.message.id).delete
        end
    end

    module_function :page_control
    module_function :start
end