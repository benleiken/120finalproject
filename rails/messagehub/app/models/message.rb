class Message < ActiveRecord::Base
	belongs_to :app
	before_save :default_values

	validates_presence_of :app_id, :content, :username


	validates_length_of :content,
   		:in => 1..160        


   	validates_length_of :username,
   		:in => 3..60         




	validates :username, format: { with: /\A[a-zA-Z0-9\-_]+\z/,
    	message: "only allows letters" }



  def default_values
    self.active ||= true
  end

end
