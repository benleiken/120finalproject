class MessagesController < ApplicationController

	protect_from_forgery except: :create
	before_action :set_message, only: [:show]
  def index
  	@messages = Message.where("created_at > ?", Time.at(params[:after].to_i + 1))
  end

  def create
    @message = Message.new(message_params)

    @message.save
  end

  def show
  end

  def selection
    @messages = Message.where("id > ? AND id < ?", 13 + params[:offset].to_i, params[:offset].to_i + 24 )
  end

  def length
    @length = Message.size()
  end


private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:app_id, :content, :username, :active)
	end
end
