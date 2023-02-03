class ExportAvitoJob < ApplicationJob
  queue_as :default

  def perform
    # Do something later
    Services::Export.avito
  end
end
