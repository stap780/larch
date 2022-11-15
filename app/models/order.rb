class Order < ApplicationRecord
  belongs_to :client
  belongs_to :user
  validates :client_id, presence: true
  after_initialize :set_default_new
  # after_commit :send_mail_to_operator , on: :create
  # after_commit :check_manager_and_send_notification, if: :persisted?

  delegate :title, to: :company, prefix: true, allow_nil: true

  STATUS = ["Новый", "В работе", "Отменен"]





  private


  def set_default_new
      self.status = Order::STATUS.first if new_record?
  end

  def check_manager_and_send_notification
      OrderMailer.order_ready(self).deliver_now if saved_change_to_user_id?
  end

  def send_mail_to_operator
    OrderMailer.order_new(self).deliver_now
  end

end
