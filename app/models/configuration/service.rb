class Service < Configuration
  assigned_and_assigned_to :pools
  assigned_and_assigned_to :nodes,    :through => :pools
  assigned                 :roles
  assigned                 :elements, :through => :roles
  
  has_scopes
end