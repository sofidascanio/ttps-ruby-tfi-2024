class SalesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sale, only: %i[ show edit update destroy ]

  # GET /sales or /sales.json
  def index
    @sales = Sale.all
  end

  # GET /sales/1 or /sales/1.json
  def show
  end

  # GET /sales/new
  def new
    @sale = Sale.new
    @sale.product_sales.build 
    @products = Product.all
  end

  # GET /sales/1/edit
  def edit
    @products = Product.all
  end

  # POST /sales or /sales.json
  def create
    Sale.transaction do
      @sale = Sale.new(sale_params)
      @sale.user = current_user
  
      @sale.product_sales.each do |product_sale|
        if product_sale.product && !product_sale.marked_for_destruction?
          product_sale.price = product_sale.product.price
        end
      end
  
      respond_to do |format|
        # Chequear stock antes de intentar guardar
        if @sale.valid? && check_stock_availability(@sale)
          if @sale.save
            # Actualizar el stock de los productos
            @sale.product_sales.each do |product_sale|
              product = product_sale.product
              product.update!(stock: product.stock - product_sale.quantity)
            end
  
            format.html { redirect_to @sale, notice: "Venta creada exitosamente." }
            format.json { render :show, status: :created, location: @sale }
          else
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @sale.errors, status: :unprocessable_entity }
          end
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @sale.errors, status: :unprocessable_entity }
        end
      end
    end
  end
  

  # PATCH/PUT /sales/1 or /sales/1.json
  def update    
    # no se usa el update, consultar

    respond_to do |format|
      if @sale.update(sale_params)
        format.html { redirect_to @sale, notice: "Se actualizó la venta." }
        format.json { render :show, status: :ok, location: @sale }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales/1 or /sales/1.json
  def destroy
    @sale.destroy!

    respond_to do |format|
      format.html { redirect_to sales_path, status: :see_other, notice: "Se eliminó la venta." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_sale
    @sale = Sale.find(params[:id]) 
  end

  # Only allow a list of trusted parameters through.
  def sale_params
    params.require(:sale).permit(:sale_price, :client, product_sales_attributes: [:id, :product_id, :quantity, :price, :_destroy])
  end

  def check_stock_availability(sale)
    sale.product_sales.each do |product_sale|
      product = product_sale.product
      if product && product.stock < product_sale.quantity
        sale.errors.add(:base, "El producto '#{product.name}' no tiene suficiente stock disponible. Stock actual: #{product.stock}, solicitado: #{product_sale.quantity}.")
        return false
      end
    end
    true
  end
end
