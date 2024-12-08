class Ability
    include CanCan::Ability

    def initialize(user)
        # inicializo un usuario para que no rompa
        user ||= User.new

        can :read, Product 
        can :read, Category

        # si no pregunto por todos, no llega nunca a los permisos de gerente/admin
        return unless user.employee? or user.manager? or user.admin?
        can :manage, Product
        can :manage, Sale 
        can :manage, Category

        return unless user.manager? or user.admin?
        can :manage, User
        cannot :create, User, role: 0
        cannot :update, User, role: 0
        cannot :assign, :admin_role

        return unless user.admin?
        can :manage, :all 
    end
end