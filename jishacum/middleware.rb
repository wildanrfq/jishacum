module JishacumMiddleware
    module MessageModifierMiddleware
        refine Discordrb::Message do
            attr_accessor :author
            attr_accessor :content
        end
    end

    module DMBlockMiddleware
        refine Discordrb::Commands::CommandContainer do
            def command(name, dm_disabled: false, **args, &block)
                super(name, **args) do |event, *args|
                    event.message.channel.private? && dm_disabled ? nil : block.call(event, *args)
                end
            end
        end
    end
end