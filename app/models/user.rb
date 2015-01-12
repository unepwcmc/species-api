class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :presence => true
  validates :role, inclusion: { in: ['default', 'admin', 'api'] }, 
                   presence: true
  validates :terms_and_conditions, acceptance: true

  after_create :generate_authentication_token

  def is_contributor?
    self.role == 'default'
  end

  def is_admin?
    self.role == 'admin'
  end

  def is_api?
    self.role == 'api'
  end

  def generate_authentication_token
    token = loop do
      t = SecureRandom.base64.tr('+/=', 'Qrt')
      break t unless User.exists?(authentication_token: t)
    end
    self.authentication_token = token
    self.save
  end
end
