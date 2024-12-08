class UsersController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user! 
    before_action :set_user, only: %i[ show edit update destroy ]

    def index
        @users = User.order(created_at: :desc).page(params[:page])
    end

    def show
    end

    def new
        @user = User.new
        @roles = User.roles.keys.map { |role| [t("roles.#{role}"), role] }
        unless can?(:assign, :admin_role)
            @roles.reject! { |_, role| role == "admin" }
        end
    end

    def create
        @user = User.new(user_params)
        if @user.save
            redirect_to @user, notice: "Usuario creado exitosamente."
        else
            @roles = User.roles.keys.map { |role| [role.humanize, role] }
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        @roles = User.roles.keys.map { |role| [t("roles.#{role}"), role] }
        unless can?(:assign, :admin_role)
            @roles.reject! { |_, role| role == "admin" }
        end
    end

    def update
        previous_role = @user.role
        if @user.update(user_params)
            if previous_role != @user.role && @user == current_user
                # usuario "admin" se cambio de rol mientras estaba logueado
                sign_out @user
                redirect_to root_path, notice: 'Se modifico su rol en el sistema. Ingrese de nuevo.'
            else
                redirect_to @user, notice: "Usuario actualizado exitosamente."
            end
        else
            @roles = User.roles.keys.map { |role| [role.humanize, role] }
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        previous_state = @user.is_deleted
        if @user.toggle!(:is_deleted)
            if previous_state
                redirect_to @user, notice: "Usuario activado exitosamente."
            else
                @user.update(password: Devise.friendly_token())
                redirect_to @user, notice: "Usuario desactivado exitosamente."
            end
        else
            if previous_state 
                redirect_to @user, alert: "Error al activar el usuario."
            else
                redirect_to @user, alert: "Error al desactivar el usuario."
            end
        end
    end

    private

    def set_user
        @user = User.find(params[:id])
    end

    def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :username, :telephone, :role, :entered_at)
    end
end
  