class UsersController < ApplicationController
    load_and_authorize_resource
    before_action :authenticate_user! 
    before_action :set_user, only: %i[ show edit update destroy ]
    before_action :set_roles, only: %i[ new edit ]

    def index
        @users = User.order(created_at: :desc).page(params[:page])
    end

    def show
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            redirect_to @user, notice: "Usuario creado exitosamente."
        else
            # no se si llamar solo a la función o asignarlo por las dudas
            @roles = set_roles
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        previous_role = @user.role
        if @user.update(user_params)
            if previous_role != @user.role && @user == current_user
                # si el usuario se cambio su propio rol, cierra la sesión
                sign_out @user
                redirect_to root_path, notice: 'Se modifico su rol en el sistema. Ingrese de nuevo.'
            else
                redirect_to @user, notice: "Usuario actualizado exitosamente."
            end
        else
            @roles = set_roles
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        previous_state = @user.is_deleted
        if @user.update(is_deleted: !previous_state)
          if previous_state
            # solucion temporal para restaurar al usuario
            @user.update(password: "123456")
            redirect_to @user, notice: "Se restauro al usuario."
          else
            @user.update(password: Devise.friendly_token())
            redirect_to @user, notice: "Se bloqueo al usuario."
          end
        else
            message = previous_state ? "No se pudo restaurar al usuario." : "No se pudo desactivar al usuario."
            redirect_to @user, alert: message
        end
    end

    private

    def set_roles
        # listado de roles
        # si no tiene permiso para crear/modificar administradores, saco la opcion "administrador"
        @roles = User.roles.keys.map { |role| [t("roles.#{role}"), role] }
        unless can?(:assign, :admin_role)
            @roles.reject! { |_, role| role == "admin" }
        end
        return @roles
    end

    def set_user
        @user = User.find(params[:id])
    end

    def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :username, :telephone, :role, :entered_at)
    end
end
  