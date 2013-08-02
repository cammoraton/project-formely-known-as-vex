module ConfigurationHelper
  def vex_path(options)
    polymorphic_path(vex_class.to_s.downcase, options)
  end
  
  def vex_class
    self.class.const_get(params[:type].singularize.camelize)
  end
end