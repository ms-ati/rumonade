class User < ActiveRecord::Base
  has_many :articles

  def self.eager_all
    self.includes(:articles).all
  end
end

