require "discorb"
require "dispander"

client = Discorb::Client.new

client.once :standby do
  puts "Logged in as #{client.user}"
end

client.load_extension(Dispander::Core)

client.run ENV["DISCORD_BOT_TOKEN"]
