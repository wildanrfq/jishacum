require "discordrb"
require "http"
require "open3"

require_relative "../helper"

module ShellCommand
    extend Discordrb::EventContainer

    message do |event|
        message = event.message
        prefix = event.bot.prefix

        if message.content.start_with?(prefix + "jsc sh ") || message.content.start_with?(prefix + "jsc shell ")
            # usage : !jsc sh echo 'hi'
            break unless owner event

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
end