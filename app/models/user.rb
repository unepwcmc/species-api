# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  role                   :string(255)      default("default")
#  authentication_token   :string(255)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true
  validates :role, inclusion: { in: ['default', 'admin', 'api'] },
                   presence: true
  validates :terms_and_conditions, acceptance: true
  validates :organisation, presence: true
  validates :is_cites_authority, inclusion: { in: [true, false] }

  has_many :api_requests

  before_create :set_default_role
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
    self.update_attribute(:authentication_token, token)
  end

  private
  def set_default_role
    self.role ||= 'api'
  end

end
