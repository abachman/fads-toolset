require 'open-uri'
require 'nokogiri'

class GettextController < ApplicationController
  def index
    @text = ''
    begin
      doc = Nokogiri::HTML(open(params[:uri]))
      @text = doc.xpath("//text()").to_s
      @status = {:status => 'ok'}
    rescue => ex
      @status = {
        :status => 'error',
        :error => {
          :message => ex.message,
          :type => ex.class
        } 
      }
    end

    respond_to do |format|
      format.json {
        render :json => {:text => @text, :status => @status}
      }
      format.html {
        if @status[:status] == 'error'
          render :text => @status[:error][:message]
        else
          render :text => @text
        end
      }
    end
  end
end
