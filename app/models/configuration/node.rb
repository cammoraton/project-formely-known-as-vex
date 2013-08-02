class Node < Configuration
  assigned_and_assigned_to :pools
  assigned_and_assigned_to :services, :through => :pools
  assigned                 :roles,    :through => :pools
  assigned                 :elements, :through => [ :roles, :pools ]
  
  deduplicates_on :pools
  
  has_facts
  simulates_hiera
  #auto_indexes_data
end