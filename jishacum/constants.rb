JISHACUM_HELP_DESCRIPTION = %{Jishacum base command.

Commands:
`jishacum / jsc` : Shows some informations about the bot.
`jsc shutdown / exit` : Shuts down the bot.
`jsc restart / r` : Restarts the bot.
`jsc eval / e <code>` : Evaluate a code.
`jsc run <code>` : Run a Ruby code.
`jsc exec <member_id> <command>` : Run a command with a different member.
`jsc repeat / rpt <times> <command>` : Repeat a command in the specified times.
`jsc debug / dbg <command> [*args]` : Debug a command, *args is optional in case the command needs arguments.
`jsc shell / sh <command_line>` : Run a command line in the shell.
}

RELATIVES = [
    "config",
    "errors",
    "helper",
    "middleware",
    "paginator"
]

EXTERNALS = [
    "benchmark",
    "discordrb",
    "get_process_mem",
    "http",
    "open3"
]