class KpsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_order
  before_action :set_kp, only: %i[show edit update destroy]

  # GET /kps
  def index
    # @kps = Kp.all
    @search = @order.kps.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @kps = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /kps/1
  def show; end

  # GET /kps/new
  def new
    @kp = @order.kps.build
  end

  # GET /kps/1/edit
  def edit; end

  # POST /kps
  def create
    @kp = @order.kps.build(kp_params)

    respond_to do |format|
      if @kp.save
        format.html { redirect_to edit_order_path(@order), notice: 'Kp was successfully created.' }
        format.json { render :show, status: :created, location: @kp }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kps/1
  def update
    respond_to do |format|
      if @kp.update(kp_params)
        format.html { redirect_to edit_order_path(@order), notice: 'Kp was successfully updated.' }
        format.json { render :show, status: :ok, location: @kp }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kps/1
  def destroy
    @kp.destroy
    respond_to do |format|
      format.html { redirect_to order_kps_path(@order), notice: 'Kp was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /kps
  def delete_selected
    @kps = @order.kps.find(params[:ids])
    @kps.each do |kp|
      kp.destroy
    end
    respond_to do |format|
      format.html { redirect_to order_kps_path(@order), notice: 'Kp was successfully destroyed.' }
      format.json { render json: { status: 'ok', message: 'destroyed' } }
    end
  end

  def print1
    @kp = Kp.find(params[:id])
    puts @kp.present?
    @company = @kp.order.company
    respond_to do |format|
      format.html
      format.pdf do
          render :pdf => "КП1 #{@kp.id}",
                 :template => "kps/print1",
                 :show_as_html => params.key?('debug')
        end
    end
  end

  def print2
    @kp = Kp.find(params[:id])
    @company = @kp.order.company
    respond_to do |format|
      format.html
      format.pdf do
          render :pdf => "КП2 #{@kp.id}",
                 :template => "kps/print2",
                 :show_as_html => params.key?('debug')
        end
    end
  end

  def print3
    @kp = Kp.find(params[:id])
    @company = @kp.order.company
    respond_to do |format|
      format.html
      format.pdf do
          render :pdf => "КП3 #{@kp.id}",
                 :template => "kps/print3",
                 :show_as_html => params.key?('debug')
        end
    end
  end
  # это для модалки для загрузки файла
  def file_import
    respond_to do |format|
      format.js
    end
  end

  def import
    @kp = Kp.find(params[:id])
    Kp.import(params[:file], params[:order_id], params[:id])
    flash[:notice] = 'Products was successfully import'
    redirect_to edit_order_kp_path(@order, @kp)
	end


  private

  def get_order
    @order = Order.find(params[:order_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_kp
    @kp = @order.kps.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def kp_params
    params.require(:kp).permit(:vid, :status, :title, :order_id, kp_products_attributes: %i[id quantity price sum product_id _destroy])
  end
end
