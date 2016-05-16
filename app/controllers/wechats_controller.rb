require 'digest/sha1'
require 'nokogiri'
class WechatsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authorize
  before_action :check_signature?
  
  @@token = "tkn_wechat_afei1231_hotmail"
  
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
    Digest::SHA1.hexdigest([params[:timestamp], params[:nonce], @@token].sort.join ) == params[:signature]
  end
    
end
