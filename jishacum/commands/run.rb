require "discordrb"
require "http"

require_relative "../helper"

module RunCommand
    extend Discordrb::EventContainer

    message do |event|
        message = event.message
        prefix = event.bot.prefix
        if message.content.start_with?(prefix+"jsc run ") || message.content.start_with?(prefix+"jsc run\n")
            # usage: !jsc run <code> || e.g !jsc run puts "hello"
            break unless owner event

            channel.start_typing
            code = message.content.sub(prefix+"jsc run ", "").sub(prefix+"jsc run\n", "")

            if code.start_with?("```rb\n") && code.end_with?("\n```")
                code = code[0..-4].sub("```rb\n", "")
            elsif code.start_with?("```ruby\n") && code.end_with?("\n```")
                code = code[0..-4].sub("```ruby\n", "")
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
        end
    end
end