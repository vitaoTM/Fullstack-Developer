class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { user: 0, admin: 1 }

  has_one_attached :avatar_image

  attr_accessor :avatar_url

  validates :full_name, presence: true

  before_validation :download_avatar_from_url, if: -> { avatar_url.present? }
  after_create_commit :broadcast_dashboard_update
  after_update_commit :broadcast_dashboard_update, if: :saved_change_to_role?
  after_destroy_commit :broadcast_dashboard_update

  private

  def download_avatar_from_url
    require "down"
    begin
      tempfile = Down.download(avatar_url)
      self.avatar_image.attach(io: tempfile, filename: tempfile.original_filename)
    rescue Down::Error => e
      Rails.logger.error "Avatar URL download failed: #{e.message}"
      errors.add(:avatar_url, "is not a valid image URL or could not be downloaded")
    end
  end

  def broadcast_dashboard_update
    Turbo::StreamsChannel.broadcast_update_to(
    "admin_dashboard_stats",
    target: "admin_dashboard_stats",
    partial: "admin/dashboard/stats",
    locals: {
      total_users: User.count,
      users_by_role: User.group(:role).count
      }
    )
  end
end
