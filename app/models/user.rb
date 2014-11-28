class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  #include SentientUser
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable
  # attr_accessible :email, :name, :password, :password_confirmation,
  #   :remember_me, :role, :terms_and_conditions

  # has_many :ahoy_visits, dependent: :nullify, class_name: 'Ahoy::Visit' 

  validates :email, :uniqueness => true, :presence => true
  validates :name, :presence => true
  validates :role, inclusion: { in: ['default', 'admin', 'api'] }, 
                   presence: true
  validates :terms_and_conditions, acceptance: true

  def is_contributor?
    self.role == 'default'
  end

  def is_admin?
    self.role == 'admin'
  end

  def is_api?
    self.role == 'api'
  end
end
