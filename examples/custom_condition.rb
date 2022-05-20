require "discorb"
require "dispander"

client = Discorb::Client.new

client.once :standby do
  puts "Logged in as #{client.user}"
end

dispander = Dispander::Core.new(client)

def dispander.should_expand?(base_message, ids)
  ENV["ALLOWED_GUILDS"].split(",").include?(ids[0])
end

client.load_extension(dispander)

client.run ENV["DISCORD_BOT_TOKEN"]
