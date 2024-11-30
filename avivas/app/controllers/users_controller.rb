class UsersController < ApplicationController
    before_action :authenticate_user! 
    before_action :set_user, only: %i[ show edit update destroy ]

    def index
        @users = User.all
    end

    def show
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            redirect_to users_path, notice: "Usuario creado exitosamente."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @user.update(user_params)
            redirect_to @user, notice: "Usuario actualizado exitosamente."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @user.destroy
        redirect_to users_path, notice: "Usuario eliminado exitosamente."
    end

    private

    def set_user
        @user = User.find(params[:id])
    end

    def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :username, :telephone, :role, :entered_at)
    end
end
  