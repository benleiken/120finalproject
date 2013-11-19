class App < ActiveRecord::Base
  	before_save :default_values
	has_many :messages

	validates_presence_of :app_title, :description



  def default_values
    self.active ||= true
  end
end
