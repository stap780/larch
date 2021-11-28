class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [:webhook]
  before_action :authenticate_user_role!, except: [:webhook]
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  def index
    #@orders = Order.all
    @search = Order.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @orders = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /orders/1
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /orders/1
  def update
  respond_to do |format|
    if @order.update(order_params)
      format.html { redirect_to orders_url, notice: "Order was successfully updated." }
      format.json { render :show, status: :ok, location: @order }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @order.errors, status: :unprocessable_entity }
    end
  end
  end

  # DELETE /orders/1
  def destroy
  @order.destroy
  respond_to do |format|
    format.html { redirect_to orders_url, notice: "Order was successfully destroyed." }
    format.json { head :no_content }
  end
  end

# POST /orders
  def delete_selected
    @orders = Order.find(params[:ids])
    @orders.each do |order|
        order.destroy
    end
    respond_to do |format|
      format.html { redirect_to orders_url, notice: "Order was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end


  def download
    Order.download
    flash[:notice] = 'Orders was successfully downloaded'
    redirect_to orders_path
  end

  def webhook
    Order.one_order(params)
    flash[:notice] = 'Order was successfully downloaded'
    redirect_to orders_path
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def order_params
      params.require(:order).permit(:status, :number, :client_id, :company_id)
    end
end
