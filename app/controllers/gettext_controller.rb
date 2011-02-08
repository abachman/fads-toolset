require 'open-uri'
require 'nokogiri'

class GettextController < ApplicationController
  def index
    @text = ''
    @urls = []
    begin
      doc = Nokogiri::HTML(open(params[:uri]))
      # clear script nodes from body
      doc.xpath("//body/script").each do |stag|
        stag.remove
      end
      @text = doc.xpath("//body//text()").to_s

      seen = []
      @urls = doc.xpath("//a/@href").map {|href|
        href.to_s
      }.select {|href|
        outval = (/^http/ =~ href && !seen.include?(href))
        seen << href
        outval
      }
      @status = {:status => 'ok'}
    rescue => ex
      @status = {
        :status => 'error',
        :error => {
          :message => ex.message,
          :error_type => ex.class.to_s
        } 
      }
    end

    respond_to do |format|
      format.json {
        render :json => {:text => @text, :urls => @urls}.merge(@status)
      }
      format.html {
        if @status[:status] == 'error'
          render :text => @status[:error][:message]
        else
          render :text => "%s\n\n%s" % [@text, @urls.join("\n")]
        end
      }
    end
  end
end
