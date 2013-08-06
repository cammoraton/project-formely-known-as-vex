class Element < Configuration
  routed_as "classes"
  
  assigned_to :nodes,    :through => [ :pools, :roles ]
  assigned_to :pools,    :through => :roles
  assigned_to :services, :through => :roles
  assigned_to :roles
  
  has_scopes
  scoped_on [ :environment, :facts ]
  
  has_cache
  #auto_indexes_data
end