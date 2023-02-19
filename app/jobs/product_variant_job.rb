class ProductVariantJob < ApplicationJob
  queue_as :default

  def perform(product)
    # Do something later
    Services::Product.create_variants(product)
  end
end
