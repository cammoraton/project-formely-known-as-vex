Vex::Application.routes.draw do
  Vex::Application.config.dynamic_models.each do |type|
    route = self.class.const_get(type.camelize).routing_path
    get "/#{route}"              => "configuration#index",
                   :type        => type,
                   :action      => "index", 
                   :constraints => { :id => /[\w\.:\ -_%]+?/, :format => /html|json|yaml/ }, 
                   :as          => type
    post "/#{route}"            => "configuration#create", 
                   :type        => type,
                   :action      => "create",
                   :as          => type
    get "/#{route}/new"          => "configuration#new",
                   :type        => type,
                   :action      => "new",
                   :as          => "new_#{type.singularize}"
    get "/#{route}/:id/edit"     => "configuration#edit",
                   :type        => type,
                   :action      => "edit", 
                   :constraints => { :id => /[\w\.:\ -_%]+?/, :format => /html/ }, 
                   :as          => "edit_#{type.singularize}"
    # Basic dependencies
    get "/#{route}/:id/triggers" => "configuration#triggers",
                   :type        => type,
                   :action      => "edit", 
                   :constraints => { :id => /[\w\.:\ -_%]+?/, :format => /json/ }, 
                   :as          => "triggers_#{type.singularize}"
    get "/#{route}/:id/triggered_by" => "configuration#triggered_by",
                   :type        => type,
                   :action      => "edit", 
                   :constraints => { :id => /[\w\.:\ -_%]+?/, :format => /json/ }, 
                   :as          => "triggered_by_#{type.singularize}"
    if self.class.const_get(type.camelize).vex_scoped == true
      get "/#{route}/:id(/:scope)" => "configuration#show", 
                     :type        => type,
                     :action      => "show", 
                     :constraints => { :id => /[\w\.:\ -_%]+?/, :scope => /[\w\.:%\ \/]+?/, :format => /html|json|yaml/ },
                     :as          => "#{type.singularize}"
    else
      get "/#{route}/:id" => "configuration#show", 
                     :type        => type,
                     :action      => "show", 
                     :constraints => { :id => /[\w\.:\ -_%]+?/, :format => /html|json|yaml/ },
                     :as          => "#{type.singularize}"
    end
    put "/#{route}/:id"          => "configuration#update",
                   :type        => type, 
                   :action      => "update",
                   :constraints => { :id => /[\w\.:\ -_%]+?/, :format => /html/ }
    delete "/#{route}/:id"       => "configuration#destroy",
                   :type        => type, 
                   :action      => "destroy",
                   :constraints => { :id => /[\w\.:\ -_%]+?/, :format => /html/ }
  end
end
