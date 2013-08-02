class ConfigurationController < ApplicationController
  protect_from_forgery
  include ConfigurationHelper
  
  def new
    @object = vex_class.new()
  end

  def destroy
    @object = vex_class.find_by_name(params[:id])
    @object.destroy
  end

  def create
    @object = vex_class.new(params[vex_class.to_s.downcase.to_sym])
    if @object.save
      redirect_to proc { vex_path(:id => @object.name) }
    end
  end

  def update
    @object = vex_class.find_by_name(params[:id])
    @object.attributes = params[vex_class.to_s.downcase.to_sym]
    if @object.save
      redirect_to proc { vex_path(:id => @object.name) }
    end
  end

  def index
    unless params[:q].nil?
      @objects = vex_class.where("name" => Regexp.new(params[:q])).all
    else
      @objects = vex_class.all
    end
    respond_to do |format|
      format.html
      format.json { render :json => @objects.map{ |a| { :id => a._id, :name => a.name } } }
    end
  end

  def edit
    @object = vex_class.find_by_name(params[:id])
  end
  
  def show
    @object = vex_class.find_by_name(params[:id])
    respond_to do |format|
      format.html
      format.json { render :json => @object.to_json }
      format.yaml { render :text => @object.to_yaml, :content_type => 'text/yaml' }
    end
  end
  
  def triggers
    @object = vex_class.find_by_name(params[:id])
    respond_to do |format|
      format.json { render :json => @object.dependencies.triggers.to_json }
    end 
  end
  
  def triggered_by
    @object = vex_class.find_by_name(params[:id])
    respond_to do |format|
      format.json { render :json => @object.dependencies.triggered_by.to_json }
    end 
  end
end