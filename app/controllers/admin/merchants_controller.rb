class Admin::MerchantsController < ApplicationController
  def index
    @enabled_merchants = Merchant.enabled_merchants
    @disabled_merchants = Merchant.disabled_merchants
    @top_merchants = Merchant.merchants_top_5
  end

  def show
    @merchant = Merchant.find(params[:id])
  end

  def edit
    @merchant = Merchant.find(params[:id])
  end

  def update
    @merchant = Merchant.find(params[:id])
    if params[:name] && params[:name].gsub(' ', '') == ''
      flash[:notice] = 'Empty name not permitted. Please try again.'
      redirect_to edit_admin_merchant_path(@merchant)
    elsif params[:name]
      @merchant.update(merchant_params)
      flash[:notice] = 'Merchant has been successfully updated.'
      redirect_to admin_merchant_path(@merchant)
    elsif params[:enabled]
      @merchant.update(merchant_params)
      redirect_to admin_merchants_path
    end
  end

  def new; end

  def create
    @merchant = Merchant.new(merchant_params)
    @merchant.save
    flash.notice = "New merchant #{@merchant.name} Created"
    redirect_to admin_merchants_path
  end

  private

  def merchant_params
    params.permit(:name, :enabled)
  end
end
