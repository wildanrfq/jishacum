# Jishacum

Jishacum is a debugging and testing container for [discordrb](https://github.com/shardlab/discordrb) bots. Jishacum is heavily inspired by [Jishaku](https://github.com/Gorialis/jishaku) (a debugging and testing cog for [discord.py](https://github.com/Rapptz/discord.py) bots). Jishacum is aliased as `jsc`.

![Jishacum Features Preview](https://cdn.discordapp.com/attachments/900443909677797396/967063480144367707/unknown.png)
# Features

### jishacum | jsc
> Show some information about the bot.
### jsc debug | dbg [command] [*args]
> Debug a command.
### jsc eval | e [code]
> Evaluate a code. You can see the shortcut variables in the [`EVAL_SHORTCUTS`](https://github.com/danrfq/jishacum/blob/main/EVAL_SHORTCUTS.md) file.
### jsc exec [member_id] [command] [*args]
> Execute a command as someone else.
### jsc repeat | rpt [number] [command] [*args]
> Repeat a command in the specified number times.
### jsc restart | r
> Restart the bot.
### jsc run [ruby_code]
> Run a Ruby code (e.g. jsc run `puts "hello"`).
### jsc shell | sh [command_line]
> Run a command line in the shell.
### jsc shutdown | exit
> Shut down the bot.

# Jishacum Installation

Obviously, you must have a ready [discordrb](https://github.com/shardlab/discordrb) bot with Bundler to use jishacum.

1. `$ git clone https://github.com/danrfq/jishacum`
2. `$ cd jishacum`
3. `$ bundle install`

After installing the bundle, you must set `OWNER_ID` or `OWNER_IDS` (if your bot is owned by a team) in the [config](https://github.com/danrfq/jishacum/blob/main/jishacum/config.rb) file. Otherwise, jishacum will not run.

```ruby
# before 

"OWNER_ID" => nil,

# after

"OWNER_ID" => 211756205721255947,

# or with OWNER_IDS

"OWNER_ID" => nil,
"OWNER_IDS" => [],

# after

"OWNER_ID" => nil,
"OWNER_IDS" => [211756205721255947, 903702557942243359],
```

You may also need to change the `MAIN_BOT_FILE_NAME` variable if your main bot's file name is not `bot.rb`.

# Include Jishacum Container to Your Bot

It's really simple, you just need to require jishacum container:
```ruby
require_relative "jishacum/jishacum"
```
and, include it to your bot:
```ruby
bot.include! Jishacum
```
That's it! Now you have jishacum container included in your bot.

A simple bot example using the jishacum container is in the [bot](https://github.com/danrfq/jishacum/blob/main/bot.rb) file.

# Support or Questions

You can ask questions in [this Discord server](https://discord.gg/rtUWkwDxHP) in the `#support` channel, or you can send me a DM in Discord: `will.#0021`.
