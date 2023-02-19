class ProductVariantJob < ApplicationJob
  queue_as :product_variant_create


  def perform(product)
    # Do something later
    
    Services::Import.create_variants(product)
  end

end
