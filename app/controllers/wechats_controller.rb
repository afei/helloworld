require 'digest/sha1'
require 'nokogiri'
class WechatsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authorize
  before_action :check_signature?
  
  @token = ""
  @appid = "wx049f75229efb0dc2"
  @secret = ""
  
  def wechat_auth
    render text: params[:echostr]
  end

  def wechat_post
    str = request.body.read.force_encoding("UTF-8")
    @doc = Nokogiri::Slop(str)
    if @doc.xml.MsgType.content == "event" and @doc.xml.Event.content == "subscribe"
      render "wechats/subscribe", layout: false, :formats => :xml
    else
      render "wechats/message", layout: false, :formats => :xml
    end
  end
  
private
  def check_signature?
    Digest::SHA1.hexdigest([params[:timestamp], params[:nonce], @token].sort.join ) == params[:signature]
  end
  
  def get_access_token
    if Rails.cache.read("access_token").nil?
      uri = URI("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{@appid}&secret=#{}")
      res = Net::HTTP.get(uri)
      result = JSON.parse(res)
      Rails.cache.write("access_token",result['access_token'],expires_in: 2.hours)
    else
      Rails.cache.read("access_token")
    end
  end
  
  def code_access_token(appid, sercet, code)
    uri = URI("https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{appid}&secret=#{sercet}&code=#{code}&grant_type=authorization_code")
    res = Net::HTTP.get(uri)
    result = JSON.parse(res)
  end
  
  def send_json(url,body)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do   |http|
      request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/json'})
      request.body=body
      puts request.body
      response=http.request request
      puts response.body
    end
  end
    
end
