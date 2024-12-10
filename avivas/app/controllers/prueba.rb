def update
    Sale.transaction do
    #   @sale = Sale.new(sale_params)
    #   @sale.user = current_user
  
    #   @sale.product_sales.each do |product_sale|
    #     if product_sale.product && !product_sale.marked_for_destruction?
    #       product_sale.price = product_sale.product.price
    #     end
    #   end

      @sale.sale_price = @sale.product_sales.sum { |ps| ps.quantity * ps.price }
  
      respond_to do |format|
        if @sale.valid? && check_stock_availability(@sale)
          if @sale.update(sale_params)
            @sale.product_sales.each do |product_sale|
                product = product_sale.product
                original_quantity = product_sale.saved_change_to_quantity&.first || product_sale.quantity
    
                # Cambio el stock de los productos
                if product_sale.saved_change_to_quantity
                  stock_difference = original_quantity - product_sale.quantity
                  product.stock += stock_difference
                  product.save!
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





    # PATCH/PUT /sales/1 or /sales/1.json
    def update
        Sale.transaction do
            # manejo los productos
            if @sale.update(sale_params)
              @sale.product_sales.each do |product_sale|
                product = product_sale.product
                original_quantity = product_sale.saved_change_to_quantity&.first || product_sale.quantity
    
                # Cambio el stock de los productos
                if product_sale.saved_change_to_quantity
                  stock_difference = original_quantity - product_sale.quantity
                  product.stock += stock_difference
                  product.save!
                end
                # el stock de los productos borrados se devuelve en la bd
    
              end
          end
        end
    
        respond_to do |format|
          if @sale.save
            format.html { redirect_to @sale, notice: "Venta actualizada exitosamente." }
            format.json { render :show, status: :created, location: @sale }
          else
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @sale.errors, status: :unprocessable_entity }
          end
        end
      
      # end del update
      end