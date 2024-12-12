class ProductsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_product, only: %i[ show edit update destroy ]
  before_action :set_categories, only: %i[ new edit create update ]

  # GET /products or /products.json
  def index
    @q = Product.ransack(params[:q])
    @products = @q.result(distinct: true).where(is_deleted: false).order(created_at: :desc).page(params[:page]).per(12)
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

    categories_to_add = params[:selected_categories] || []

    categories_to_add.each do |category_id|
      category = Category.find_by(id: category_id)
      @product.categories << category
    end

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
    # Manejo categorias
    # Agarro las dos "listas", borro las que ya no estan relacionadas, agrego las que si
    categories_to_add = params[:selected_categories] || []
    categories_to_remove = params[:available_categories] || []

    categories_to_remove.each do |category_id|
      category = Category.find(category_id)
      @product.categories.delete(category)
    end

    categories_to_add.each do |category_id|
      category = Category.find(category_id)
      @product.categories << category unless @product.categories.include?(category)
    end

    # Manejo imagenes
    # Borro las imagenes seleccionadas para eliminar
    # Agrego las nuevas imagenes (sin borrar las que ya estan agregadas)

    if params[:product][:images_to_remove].present?
      params[:product][:images_to_remove].each do |index|
        @product.images[index.to_i].purge
      end
    end

    if params[:product][:images].present?
      @product.images.attach(params[:product][:images])
    end

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
      previous_state = @product.is_deleted
      if @product.update(is_deleted: !previous_state)
        if previous_state
          @product.update(is_deleted: false, deleted_at: nil)
          redirect_to @product, notice: "Se restauro el producto."
        else
          @product.update(is_deleted: true, stock: 0, deleted_at: Time.now)
          redirect_to @product, notice: "Se elimino el producto."
        end
      else
        message = previous_state ? "No se pudo restaurar el producto." : "No se pudo eliminar el producto."
        redirect_to @product, alert: message
      end
  end

  private

  def set_categories
    @categories = Category.all
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.expect(product: [ :name, :description, :price, :stock, :color, images: [], category_ids: [] ])
  end
end
