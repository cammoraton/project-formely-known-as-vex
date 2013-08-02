class Role < Configuration
  assigned    :elements
  assigned_to :pools
  assigned_to :nodes,    :through => :pools
  assigned_to :services
  
  has_scopes
  scoped_on [ :environment, :facts ]
  #auto_indexes_data
end