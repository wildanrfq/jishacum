require "discordrb"

require_relative "middleware"
require_relative "errors"

Dir.entries("jishacum/commands")[2..-1].each {require_relative "commands/"+_1}
Dir.entries("jishacum/events")[2..-1].each {require_relative "events/"+_1}

include JishacumConfig

raise JishacumError::OwnerIDNotDefined if !JISHACUM_CONFIG["OWNER_ID"] && JISHACUM_CONFIG["OWNER_IDS"].empty?
raise JishacumError::InvalidOwnerID if !((JISHACUM_CONFIG["OWNER_ID"].class == Integer) && (17..20).include?(JISHACUM_CONFIG["OWNER_ID"].to_s.length))
raise JishacumError::InconsistentOwnerVariables if JISHACUM_CONFIG["OWNER_ID"] && !JISHACUM_CONFIG["OWNER_IDS"].empty?

module Jishacum
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    using DMBlockMiddleware if JISHACUM_CONFIG["IGNORE_DMS"]

    MODULES = [
        ButtonEvent,
        ReadyEvent,
        CatCommand,
        DebugCommand,
        EvalCommand,
        ExecCommand,
        MainCommand,
        RepeatCommand,
        RunCommand,
        ShellCommand
    ]
    
    MODULES.each {include! _1}

end