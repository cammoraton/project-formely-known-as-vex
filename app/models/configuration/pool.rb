class Pool < Configuration
  assigned_and_assigned_to :nodes
  assigned_and_assigned_to :services
  assigned                 :elements, :through => :roles
  assigned                 :roles
end