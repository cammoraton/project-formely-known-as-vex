require 'vex'

class Configuration
  include MongoMapper::Document
  include Vex::Dsl::Configuration
  include Vex::Dsl::Wrappers
  
  plugin MongoMapper::Plugins::IdentityMap
  
  key :name,           String, :required => true
  key :description,    String
  key :data,           Hash    # The actual configuration data, absent the relationships
                               # this could easily be an embedded_document but there's not much point.
  
  key :assignment_ids, Array
  
  attr_accessible :name, :description, :parameters
  attr_reader     :parameters
  
  many :assignments, :in => :assignment_ids, :class => Configuration
  
  validates_uniqueness_of :name, :scope => :_type  
  validate :reserved_word_validation
  
  before_save  :downcase_name      # Help out the routes and uniqueness validation a bit
  after_save   :fixup_assignments  # Replicate has_and_belongs_to_many kinda-sorta
  
  timestamps!                      # TIMESTAMPS!
  
  # Pass this back as an array of key/values to make the forms a little easier  
  def parameters
    params_to_array(self.data)
  end
  
  def to_param
    self.name
  end
 
  def to_json
    prep_hash.to_json
  end
  
  def to_yaml
    # Cheap hack to strip out serialization artifacts
    JSON.parse(prep_hash.to_json).to_yaml
  end
  
  private
  def prep_hash
    merge_hash = {}
    self.vex_assignments.keys.each do |key|
      route = self.class.const_get(key.to_s.singularize.camelize).routing_path
      items = self.send(key).to_a
      if route.to_s != key.to_s
        merge_hash[route] = items.map{ |a| a["name"] }
      else
        merge_hash[key]   = items.map{ |a| a["name"] }
      end
    end
    { :name => self.name }.merge(self.data).merge(merge_hash)
  end
  
  def downcase_name
    self.name = self.name.downcase
  end
  
  # Keep assignments out of data
  def reserved_word_validation
    data.keys.each do |key|
      puts "#{self.vex_assignments.keys.inspect} #{key}"
      
      if key == self.name
        errors.add( :data, "Key can not equal the name of this object")
      end
      if self.vex_assignments.keys.map{|a| self.class.const_get(a.to_s.singularize.camelize).routing_path }.include?(key)
        errors.add( :data, "Reserved word: #{key}" )
      end
    end
  end
  
  # We still need to cascade this somehow if there's no cache.
  def fixup_assignments
    # Hacks around the lack of has_and_belongs_to_many.  Significant performance hit, but only on save
    # which we don't really care about.
    Configuration.where( { :$and => [{ :_id => { :$in => self.assignment_ids }},{ :assignment_ids => { :$nin => [ self._id] }}]}).all.each do |config|
      cache_needs_updating = true
      config.push( :assignment_ids => self._id ) 
      config.reload; config.touch; config.save
    end
    Configuration.where( { :$and => [{ :_id => { :$nin => self.assignment_ids }},{ :assignment_ids => { :$in => [ self._id ] }}]}).all.each do |config|
      cache_needs_updating = true
      config.pull( :assignment_ids => self._id ) 
      config.reload; config.touch; config.save
    end
  end
end

