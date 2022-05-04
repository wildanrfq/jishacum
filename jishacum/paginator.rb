require "discordrb"

require_relative "helper"

module JishacumPaginator

    LIVE_PAGINATORS = {}

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

    module_function :start
end