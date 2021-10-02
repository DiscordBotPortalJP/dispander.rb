# dispander.rb

An extension that adds message expanding feature for discorb bot.
![image](https://user-images.githubusercontent.com/59691627/131650571-ec50bf35-c971-4aeb-9a58-8fbf9b3e759b.png)

Ruby version of [DiscordBotPortalJP/dispander](https://github.com/DiscordBotPortalJP/dispander).

## Install

Add this to Gemfile...

```ruby
gem 'dispander'
```

And run this:

    $ bundle install

Or...

    $ gem install dispander

## Usage

### Load as Extension

```ruby
require "discorb"
require "discorb"
require "dispander"

client = Discorb::Client.new

client.once :standby do
  puts "Logged in as #{client.user}"
end

client.load_extension(Dispander::Core)

client.run ENV["DISCORD_BOT_TOKEN"]
```

### Expand Manually

`Dispander::Core#dispand` to expand, `Dispander::Core#delete_message` to delete message.

```ruby
require "discorb"
require "dispander"

client = Discorb::Client.new

dispander = Dispander::Core.new(client)

client.on :message do |message|
  next if message.author.bot?

  dispander.dispand(message)
end

client.on :reaction_add do |event|
  dispander.delete_message(event)
end

client.run ENV["DISCORD_BOT_TOKEN"]
```

### Change emoji of deletion

Set emoji to `Dispander#delete_emoji`, or specify it in `Client#load_extension`.

```ruby
client.load_extension(Dispander::Core, delete_emoji: Discorb::UnicodeEmoji["x"])
```


## License

Source is open under [MIT License](https://opensource.org/licenses/MIT).
