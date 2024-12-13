class SalesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :set_sale, only: %i[ show edit update destroy ]
  before_action :set_products, only: %i[ new edit create update ]

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
  end

  # GET /sales/1/edit
  def edit
  end

  # POST /sales or /sales.json
  def create
    Sale.transaction do
      @sale = Sale.new(sale_params)
      @sale.user = current_user

      respond_to do |format|
        if @sale.valid? && check_stock(@sale)
          @sale.product_sales.each do |product_sale|
            if product_sale.product && !product_sale.marked_for_destruction?
              product_sale.price = product_sale.product.price
              product_sale.product.update!(stock: product_sale.product.stock - product_sale.quantity)
            end
          end
          if @sale.save
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
    Sale.transaction do
      respond_to do |format|
        if @sale.valid?
          if @sale.update(sale_params)
            # en el caso de que se haya borrado algun producto, para que se ejecute el callback
            @sale.product_sales.reload
            @sale.save
            @sale.product_sales.each do |product_sale|
                product = product_sale.product

                # no funciona bien el update

                if product_sale.saved_change_to_quantity
                  stock_difference = (product_sale.saved_change_to_quantity&.first || product_sale.quantity) - product_sale.quantity

                  # si stock_difference es positivo, la cantidad es menor a la anterior
                  if stock_difference > 0
                    product.stock += stock_difference
                    product.save!
                    # si stock_difference es negativo, la cantidad es mayor a la anterior
                  elsif stock_difference < 0
                    # si la cantidad es mayor a la anterior y no hay suficiente stock
                    if product.stock < stock_difference.abs
                      @sale.errors.add(:base, "El producto '#{product.name}' no tiene suficiente stock disponible. Stock actual: #{product.stock}, solicitado: #{stock_difference.abs}.")
                      product_sale.quantity = product_sale.saved_change_to_quantity&.first
                      format.html { render :edit, status: :unprocessable_entity }
                      format.json { render json: @sale.errors, status: :unprocessable_entity }
                    else
                      # hay stock
                      product.stock += stock_difference
                      product.save!
                    end
                  end
                end
              # el stock de los productos borrados se devuelve en la bd
            end

            format.html { redirect_to @sale, notice: "Venta actualizada exitosamente." }
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

  # DELETE /sales/1 or /sales/1.json
  def destroy
    @sale.update(is_deleted: true)

    @sale.product_sales.each do |product_sale|
      # Devuelvo stock al producto
      product = product_sale.product
      product.stock += product_sale.quantity
      product.update(stock: product.stock)
    end

    respond_to do |format|
      format.html { redirect_to @sale, status: :see_other, notice: "Se cancelo la venta." }
      format.json { head :no_content }
    end
  end

  private

  def set_products
    # no puedo filtrar por borrados, porque pueden estar borrados los productos de la misma venta
    @products = Product.all
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_sale
    @sale = Sale.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def sale_params
    params.require(:sale).permit(:sale_price, :client, product_sales_attributes: [ :id, :product_id, :quantity, :price, :_destroy ])
  end

  def check_stock(sale)
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
