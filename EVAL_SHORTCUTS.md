# Shortcut Variables for jishacum's Eval Command

| Shortcut           | Original                                                                                                                      |
| :----------------: | :---------------------------------------------------------------------------------------------------------------------------: |
| `author` / `au`    | [`event.author`](https://drb.shardlab.dev/main/Discordrb/Events/MessageEvent.html#author-instance_method)                     |
| `bot`              | [`event.bot`](https://drb.shardlab.dev/main/Discordrb/Events/Event.html#bot-instance_method)                                  |
| `channel` / `ch`   | [`event.channel`](https://drb.shardlab.dev/main/Discordrb/Events/MessageEvent.html#channel-instance_method)                   |
| `drb`              | [`Discordrb`](https://drb.shardlab.dev/main/Discordrb.html)                                                                   |
| `me`               | [`event.server.bot`](https://drb.shardlab.dev/main/Discordrb/Server.html#bot-instance_method)                                 |
| `message` / `msg`  | [`event.message`](https://drb.shardlab.dev/main/Discordrb/Events/MessageEvent.html#message-instance_method)                   |
| `prefix`           | [`event.bot.prefix`](https://drb.shardlab.dev/main/Discordrb/Commands/CommandBot.html#prefix-instance_method)                 |
| `ref`              | [`event.message.referenced_message`](https://drb.shardlab.dev/main/Discordrb/Message.html#referenced_message-instance_method) |
| `server` / `srv`   | [`event.server`](https://drb.shardlab.dev/main/Discordrb/Events/MessageEvent.html#server-instance_method)                     |

## There's also an Embed function to construct a new embed with.

The function takes `title`, `description`, `color`, `url` in order.

### Example usage:

![Embed Helper Function](https://cdn.discordapp.com/attachments/931897132783374397/967266677286895706/unknown.png)