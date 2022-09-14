class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update]
  before_action :set_merchant, only: [:index, :create]

  def index

  end

  def show

  end

  def new

  end

  def create
    @item = @merchant.items.new(item_params)
    @item.save
    flash.notice = "New Item #{@item.name} Created"
    redirect_to merchant_items_path(@merchant)
  end

  def edit

  end

  def update
    if params[:enabled].present?
      @item.update(item_params)
      redirect_to merchant_items_path(@item.merchant)
    else
      @item.update(item_params)
      flash.notice = "Item Successfully Updated"
      redirect_to merchant_item_path(@item.merchant, @item)
    end
  end

  private
    def item_params
      params.permit(:name, :description, :unit_price, :enabled)
    end

    def set_item
      @item = Item.find(params[:id])
    end

    def set_merchant
      @merchant = Merchant.find(params[:merchant_id])
    end
end