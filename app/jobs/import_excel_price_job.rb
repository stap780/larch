class ImportExcelPriceJob < ApplicationJob
    queue_as :excel
  
    def perform(excel_price)
      # Do something later
      Services::Import.excel_create(excel_price)
    end
  end