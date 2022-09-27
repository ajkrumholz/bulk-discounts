require './app/facades/holiday_facade'

class Merchant::BulkDiscountsController < Merchant::BaseController
  before_action :set_discount, only: %i[show destroy edit update]

  def index
    @discounts = @merchant.bulk_discounts
    @next_three_holidays = HolidayFacade.next_three_holidays
  end

  def show; end

  def new
    @discount = @merchant.bulk_discounts.new
  end

  def create
    @discount = @merchant.bulk_discounts.new(bulk_discount_params)
    if @discount.valid_discount?
      if @discount.save
        flash.notice = 'New Discount Added'
        redirect_to merchant_bulk_discounts_path(@merchant)
      else
        flash.notice = @discount.errors.full_messages.to_sentence
        redirect_to new_merchant_bulk_discount_path(@merchant)
      end
    else
      flash.notice = "Can't create a discount that will never be applied"
      redirect_to new_merchant_bulk_discount_path(@merchant)
    end
  end

  def destroy
    if @discount.invoices_in_progress?
      flash.notice = 'Unable to delete a bulk discount applied to a pending invoice'
      redirect_to merchant_bulk_discounts_path(@merchant)
    else
      @discount.destroy
      flash.notice = 'Discount deleted'
      redirect_to merchant_bulk_discounts_path(@merchant)
    end
  end

  def edit
    if @discount.invoices_in_progress?
      flash.notice = 'This discount is cannot be edited while active on an in-progress invoice!'
      redirect_to merchant_bulk_discount_path(@merchant, @discount)
    end
  end

  def update
    @discount.update(bulk_discount_params)
    if @discount.valid_discount?
      if @discount.save
        flash.notice = 'Discount updated'
        redirect_to merchant_bulk_discount_path(@merchant, @discount)
      else
        flash.notice = @discount.errors.full_messages.to_sentence
        redirect_to edit_merchant_bulk_discount_path(@merchant, @discount)
      end
    else
      flash.notice = "Can't edit a discount so that it will never be applied"
      redirect_to edit_merchant_bulk_discount_path(@merchant, @discount)
    end
  end

  private

  def bulk_discount_params
    params.require(:bulk_discount).permit(
      :discount_percent,
      :quantity_threshold
    )
  end

  def set_discount
    @discount = BulkDiscount.find(params[:id])
  end
end
