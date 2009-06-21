class FeedsController < ApplicationController
  # sample: src = http://feeds.journal.mycom.co.jp/haishin/rss/pc?format=xml

  def index
  end

  def feed
    require "open-uri"
#     # doc = REXML::Document.new(open("mycom.xml"))
    doc = REXML::Document.new(Net::HTTP.get_response(URI.parse(params[:src])).body)
    doc.elements.delete_all "//item[not(contains(@rdf:about,'#{params[:rdf_about]}'))]"
    send_data doc.to_s, :type => "text/xml; charset=UTF-8"
#    render :nothing => true
  rescue SocketError => e
    flash[:error] = e.message
    redirect_to root_path(params)
  end
end
