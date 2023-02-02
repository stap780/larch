class ExportAvitoJob < ApplicationJob
  queue_as :default

  def perform(excel_price)
    # Do something later
    Services::Export.avito
  end
end
