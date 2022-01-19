class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /products or /products.json
  def index
    # @products = Product.all
    @search = Product.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @products = @search.result.paginate(page: params[:page], per_page: 100)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to products_url, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to products_url, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def delete_selected
    @products = Product.find(params[:ids])
    @products.each do |product|
        product.destroy
    end
    respond_to do |format|
      format.html { redirect_to orders_url, notice: "Order was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end

  def delete_image
    ActiveStorage::Attachment.where(id: params[:image_id])[0].purge
    respond_to do |format|
      #format.html { redirect_to edit_product_path(params[:id]), notice: 'Image was successfully deleted.' }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.with_attached_images.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:sku, :title, :desc, :quantity, :costprice, :price, :insid, :insvarid, images: [], images_attachments_attributes: [:id, :_destroy])
    end
end
