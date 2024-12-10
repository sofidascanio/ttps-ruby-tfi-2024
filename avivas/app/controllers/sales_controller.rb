class SalesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :set_sale, only: %i[ show edit update destroy ]

  # GET /sales or /sales.json
  def index
    @sales = Sale.order(created_at: :desc).page(params[:page])
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

      @sale.sale_price = @sale.product_sales.sum { |ps| ps.quantity * ps.price }
  
      respond_to do |format|
        if @sale.valid? && check_stock(@sale)
          if @sale.save
            @sale.product_sales.each do |product_sale|
              product = product_sale.product
              product.update!(stock: product.stock - product_sale.quantity)
            end
  
            format.html { redirect_to @sale, notice: "Venta creada exitosamente." }
            format.json { render :show, status: :created, location: @sale }
          else
            @products = Product.all
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @sale.errors, status: :unprocessable_entity }
          end
        else
          @products = Product.all
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @sale.errors, status: :unprocessable_entity }
        end
      end
    end
  end
  

  # PATCH/PUT /sales/1 or /sales/1.json
    def update
      Sale.transaction do
        # calculo precio de vuelta, por si cambio
        @sale.sale_price = @sale.product_sales.sum { |ps| ps.quantity * ps.price }
    
        respond_to do |format|
          if @sale.valid?
            if @sale.update(sale_params)
              @sale.product_sales.each do |product_sale|
                  product = product_sale.product
      
                  # Cambio el stock de los productos
                  if product_sale.saved_change_to_quantity
                    # metodo de active record: saved_change_to_quantity 
                    # para saber si cambio 'quantity': si se cambio, devuelve un array con dos valores
                    # [valor previo, valor nuevo]
                    # & -> si es nil, no hace la consulta
                    # first -> devuelve el primer elemento (el valor previo)
                    # si no tiene valor, toma el valor de 'quantity'
                    previous_quantity = product_sale.saved_change_to_quantity&.first || product_sale.quantity
                    stock_difference = previous_quantity - product_sale.quantity
                    # si aumento la cantidad pedida
                    if stock_difference > 0 
                      # si la cantidad pedida es mayor al stock disponible
                      if product.stock < stock_difference
                        sale.errors.add(:base, "El producto '#{product.name}' no tiene suficiente stock disponible. Stock actual: #{product.stock}, solicitado: #{stock_difference}.")
                      else
                        product.stock += stock_difference
                        product.save!
                      end
                    else 
                      # si la cantidad pedida no es mayor al stock disponible, descuento
                      product.stock += stock_difference
                      product.save!
                    end
                  end
                  # el stock de los productos borrados se devuelve en la bd
              end
    
              format.html { redirect_to @sale, notice: "Venta actualizada exitosamente." }
              format.json { render :show, status: :created, location: @sale }
            else
              @products = Product.all
              format.html { render :new, status: :unprocessable_entity }
              format.json { render json: @sale.errors, status: :unprocessable_entity }
            end
          else
            @products = Product.all
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @sale.errors, status: :unprocessable_entity }
          end
        end
    end
  end

  # DELETE /sales/1 or /sales/1.json
  def destroy
    @sale.update(is_deleted: true)

    @sale.product_sales.each do |product_sale|
      # devuelvo stock al producto
      product = product_sale.product
      product.stock += product_sale.quantity
      product.update(stock: product.stock)
    end

    respond_to do |format|
      format.html { redirect_to sales_path, status: :see_other, notice: "Se cancelo la venta." }
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

  def check_stock(sale)
    sale.product_sales.each do |product_sale|
      product = product_sale.product
      if product && product.stock < product_sale.quantity
        sale.errors.add(:base, "El producto '#{product.name}' no tiene suficiente stock disponible. Stock actual: #{product.stock}, solicitado: #{product_sale.quantity}.")
        return false
      end
    end
    return true
  end
end
