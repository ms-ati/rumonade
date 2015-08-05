include Rumonade

class User < ActiveRecord::Base
  has_many :articles

  def self.eager_all
    self.includes(:articles).all
  end

  def first_article
  	Option(self.articles.sort_by(&:title).first)
  end
end

