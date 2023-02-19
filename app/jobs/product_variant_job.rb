class ProductVariantJob < ApplicationJob
  queue_as :product_variant_create


  def perform(product)
    # Do something later
    # Services::Product.create_variants(product)
    Services::Import.create_variants(product)
  end

end
