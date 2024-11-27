class ProductsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Se creo el producto." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    # Eliminar imágenes seleccionadas
    if params[:product][:images_to_remove].present?
      params[:product][:images_to_remove].each do |index|
        @product.images[index.to_i].purge
      end
    end

    # Agregar nuevas imágenes (sin borrar las existentes)
    if params[:product][:images].present?
      @product.images.attach(params[:product][:images])
    end

    # Actualizar otros atributos del producto
    respond_to do |format|
      if @product.update(product_params.except(:images))
        format.html { redirect_to @product, notice: "Se actualizo el producto." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
    
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Se elimino el producto." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.expect(product: [ :name, :description, :price, :stock, :color, images: [] ])
    end
end
