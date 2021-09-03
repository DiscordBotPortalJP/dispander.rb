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
require "dispander"

client = Discorb::Client.new

client.once :ready do
  puts <<~EOS
         ---------
         Logged in as #{client.user}(#{client.user.id})
         ---------
       EOS
end

client.extend(Dispander)

client.run ENV["DISCORD_BOT_TOKEN"]
```

### Expand Manually

`Dispander.dispand` to expand, `Dispander.delete_message` to delete message.

```ruby
require "discorb"
require "dispander"

client = Discorb::Client.new

client.on :message do |message|
  next if message.author.bot?

  Dispander.dispand(message)
end

client.on :reaction_add do |event|
  Dispander.delete_message(event)
end

client.run ENV["DISCORD_BOT_TOKEN"]
```

### Change emoji of deletion

Set emoji to `Dispander.delete_emoji`

```ruby
Dispander.delete_emoji = Discorb::UnicodeEmoji.new("x")

client.extend(Dispander)
```


## License

Source is open under [MIT License](https://opensource.org/licenses/MIT).
