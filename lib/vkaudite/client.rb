require 'mechanize'

module VKAudite
  class Client
    def initialize(email, pass)
      @email = email
      @pass = pass

      @agent = Mechanize.new do |a|
        a.user_agent_alias = 'Linux Firefox'
        a.follow_meta_refresh = true
      end

      page = @agent.get("https://vk.com/")

      login_form = page.forms.first
      login_form.email = @email
      login_form.pass = @pass

      @agent.submit(login_form)
    end

    def log(*args)
      VKAudite::Application.logger.debug "Client: " + args.join(" ")
    end

    def tracks(pages = 1, shuffle = false)
      audios = @agent.get("https://vk.com/audios-28956280")

      audios.search('div.audio').map do |audio|
        {
          artist: audio.search('b//a').text.strip,
          title: audio.search('span.title').text.strip,
          url: audio.search('input').attr('value').value[/[^\?]*/],
          duration: audio.search('input').attr('value').value[/(?<=,).+/].to_i
        }
      end
    end
  end
end

