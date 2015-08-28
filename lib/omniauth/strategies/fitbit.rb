require 'omniauth'
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Fitbit < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "fitbit"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
          :site               => 'https://api.fitbit.com',
          :authorize_url      => '/oauth2/authorize',
          :token_url          => '/oauth2/token'
      }
      option :token_params, {
        :headers => {
          'Authorization' => "Basic " + Base64.encode64("#{self.default_options.client_id}:#{self.default_options.client_secret}")
        }
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid do
        access_token.params['encoded_user_id']
      end

      info do
        {
          :name         => raw_info['user']['displayName'],
          :full_name    => raw_info['user']['fullName'],
          :display_name => raw_info['user']['displayName'],
          :nickname     => raw_info['user']['nickname'],
          :gender       => raw_info['user']['gender'],
          :about_me     => raw_info['user']['aboutMe'],
          :city         => raw_info['user']['city'],
          :state        => raw_info['user']['state'],
          :country      => raw_info['user']['country'],
          :dob          => !raw_info['user']['dateOfBirth'].empty? ? Date.strptime(raw_info['user']['dateOfBirth'], '%Y-%m-%d'):nil,
          :member_since => Date.strptime(raw_info['user']['memberSince'], '%Y-%m-%d'),
          :locale       => raw_info['user']['locale'],
          :timezone     => raw_info['user']['timezone']
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end


      def raw_info
        if options[:use_english_measure] == 'true'
          @raw_info ||= MultiJson.load(access_token.request('get', 'https://api.fitbit.com/1/user/-/profile.json', { 'Accept-Language' => 'en_US' }).body)
        else
          @raw_info ||= MultiJson.load(access_token.get('https://api.fitbit.com/1/user/-/profile.json').body)
        end
      end
    end
  end
end
