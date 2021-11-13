class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :authenticate_user_role!

  # GET /companies or /companies.json
  def index
    # @companies = Company.all
    @search = Company.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @companies = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /companies/1 or /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies or /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        format.html { redirect_to companies_url, notice: "Company was successfully created." }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to companies_url, notice: "Company was successfully updated." }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: "Company was successfully destroyed." }
      format.json { head :no_content }
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
    def set_company
      @company = Company.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.require(:company).permit(:our_company, :title, :fulltitle, :uraddress, :factaddress, :inn, :kpp, :ogrn, :okpo, :bik, :banktitle, :bankaccount, images: [])
    end
end
