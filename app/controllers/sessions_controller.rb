class SessionsController < ApplicationController
  def new
  end

  def inquire
    case params[:provider]
    when "google"
      url = "https://www.google.com/accounts/o8/id"
    else
      url = params[:url]
    end
    oidreq = consumer.begin(url)
    # TODO: get nickname or kind
#     sregreq = OpenID::SReg::Request.new
#     sregreq.request_fields(['nickname'], true)
#     oidreq.add_extension(sregreq)
    redirect_to oidreq.redirect_url(root_url, identify_session_url)
  end

  def identify
    oidresp = consumer.complete(params.reject{|k,v|request.path_parameters[k]}, identify_session_url)
    case oidresp.status
    when OpenID::Consumer::SUCCESS
      flash[:success] = ("Verification of #{oidresp.display_identifier} succeeded.")
#       sreg_resp = OpenID::SReg::Response.from_success_response(oidresp)
#       flash[:success] += sreg_resp.data.inspect
      # TODO: User.find or redirect ot users#new
      user = User.find_or_create_by_identity(oidresp.identity_url)
      redirect_to session.delete(:return_to) || root_path
      set_current_user(user)
    when OpenID::Consumer::FAILURE
      if oidresp.display_identifier
        flash[:error] = ("Verification of #{oidresp.display_identifier} failed: #{oidresp.message}")
      else
        flash[:error] = "Verification failed: #{oidresp.message}"
      end
      redirect_to new_session_path
    when OpenID::Consumer::SETUP_NEEDED
      flash[:alert] = "Immediate request failed - Setup Needed"
      redirect_to new_session_path
    when OpenID::Consumer::CANCEL
      flash[:alert] = "OpenID transaction cancelled."
      redirect_to new_session_path
    end
  end

  # logout
  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def consumer
    require "openid"
    require 'openid/store/filesystem'
    require 'openid/extensions/sreg'

    store = OpenID::Store::Filesystem.new(Rails.root.join("db").join("cstore")) # TODO: the path should be in config
    @consumer ||= OpenID::Consumer.new(session, store)
  end
end
