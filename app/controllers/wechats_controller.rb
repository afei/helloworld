require 'digest/sha1'
class WechatsController < ApplicationController
  before_action 
  @@token = "tkn_wechat_afei1231_hotmail"
  def wechat_auth
    if check_signature? 
      return render text: params[:echostr]
    end
  end

  def wechat_post
  end
  
private
  def check_signature?
    Digest::SHA1.hexdigest ([params[:timestamp], params[:nonce], @@token].sort.join ) == params[:signature]
  end
    
end
