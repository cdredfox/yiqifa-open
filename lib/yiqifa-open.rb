#encoding:utf-8
require 'net/http'
require "openssl"
require "base64"
require "yaml"
require "yiqifa-open/config"

class YiqifaOpen

  def initialize
    if File.exists?('config/yiqifa.yml')
      yiqifa_config = YAML.load_file('config/yiqifa.yml')[ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"]
      Yiqifa::Config.api_key=yiqifa_config["api_key"]
      Yiqifa::Config.api_secret==yiqifa_config["api_secret"]
    else
      puts "\n\n=========================================================\n\n" +
         "  You haven't made a config/yiqifa.yml file.\n\n  You should.  \n\n  The yiqifa-open gem will work much better if you do\n\n" +
         "  Please set Yiqifa::Config.api_key and \n  Yiqifa::Config.api_secret\n  somewhere in your initialization process\n\n" +
         "=========================================================\n\n"
    end
  end
  
	def exec_api(api_url="",b_params={})
    
		app_secret=Yiqifa::Config.api_key
		
    app_key=Yiqifa::Config.api_secret
		oauth_params={
			:oauth_consumer_key=>app_key,
			:oauth_nonce=>Time.now.to_i,
			:oauth_signature_method=>"HMAC-SHA1",
			:oauth_timestamp=>Time.now.to_i,
			:oauth_token=>"openyiqifa",
			:oauth_version=>"1.0"
		}
		oauth_params_str=""
		oauth_params.each_pair do |k,v|
			if oauth_params_str==""
				oauth_params_str= k.to_s+"=\""+v.to_s+"\"";
			else
				oauth_params_str+= ","+k.to_s+"=\""+v.to_s+"\"";
			end
		end
		params=oauth_params.merge(b_params).sort_by{|k|
			k.to_s
		}
		params_map={}
		params.map { |key, value| params_map[key]=URI.encode(value.to_s) }
		params_string=""
		params_map.each_pair do |k,v|
			if params_string==""
				params_string=k.to_s+"%3D"+v.to_s
			else
				params_string=params_string+"%26"+k.to_s+"%3D"+v.to_s
			end
		end
		base_str="GET&"+URI.escape(api_url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))+"&"+params_string
		key=app_secret+"&openyiqifa"
		sign=Base64.encode64 OpenSSL::HMAC.digest("SHA1", key, base_str)
		uri = URI(api_url)
		uri.query = URI.encode_www_form(b_params)
		req = Net::HTTP::Get.new(uri.request_uri)
		oauth_params_str = "OAuth " + oauth_params_str + ",oauth_signature=\"" + sign.strip + "\"";
		req['Authorization']=oauth_params_str
		res = Net::HTTP.start(uri.hostname, uri.port) {|http|
		  http.request(req)
		}
	  res.body
	end
end