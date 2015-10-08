require 'yaml'

require_relative 'vkaudite/client'
require_relative 'vkaudite/application'

module VKAudite
  def self.start
    vk_config = YAML.load_file('config/vk.yml')

    client = Client.new(
      vk_config['vk_accaunt']['email'],
      vk_config['vk_accaunt']['pass']
    )
    application = Application.new(client)

    Signal.trap('SIGINT') do
      application.stop      
    end

    application.run
  end
end
