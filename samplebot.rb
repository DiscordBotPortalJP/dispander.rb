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
