class KpProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_user_role!
  before_action :set_kp_product, only: [:show, :edit, :update, :destroy]

  # GET /kp_products
  def index
    #@kp_products = KpProduct.all
    @search = KpProduct.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @kp_products = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /kp_products/1
  def show
  end

  # GET /kp_products/new
  def new
    @kp_product = KpProduct.new
  end

  # GET /kp_products/1/edit
  def edit
  end

  # POST /kp_products
  def create
    @kp_product = KpProduct.new(kp_product_params)

    respond_to do |format|
      if @kp_product.save
        format.html { redirect_to @kp_product, notice: "Kp product was successfully created." }
        format.json { render :show, status: :created, location: @kp_product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kp_product.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /kp_products/1
  def update
  respond_to do |format|
    if @kp_product.update(kp_product_params)
      format.html { redirect_to @kp_product, notice: "Kp product was successfully updated." }
      format.json { render :show, status: :ok, location: @kp_product }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @kp_product.errors, status: :unprocessable_entity }
    end
  end
  end

  # DELETE /kp_products/1
  def destroy
  @kp_product.destroy
  respond_to do |format|
    format.html { redirect_to kp_products_url, notice: "Kp product was successfully destroyed." }
    format.json { head :no_content }
  end
  end

# POST /kp_products
  def delete_selected
    @kp_products = KpProduct.find(params[:ids])
    @kp_products.each do |kp_product|
        kp_product.destroy
    end
    respond_to do |format|
      format.html { redirect_to kp_products_url, notice: "Kp product was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kp_product
      @kp_product = KpProduct.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def kp_product_params
      params.require(:kp_product).permit(:quantity, :price, :sum, :kp_id, :product_id)
    end
end
