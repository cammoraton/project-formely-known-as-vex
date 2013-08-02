$(function() {
 var TabHeaderTemplate = "<li><a href='##{tabId}'>#{label}</a><span class='ui-icon ui-icon-close'></span></li>",
     CompleteTabHeader = "<div id='#{parentTabId}_container'>" +
                         "<div class='data'>" +
                         "<div id='#{parentTabId}' class='#{tab_class}'>" +
                         "  <ul>" +
                         "    <li><a href='##{parentTabId}_default'>Default</a></li>" +
                         "  </ul>" +
                         "<div id='#{parentTabId}_default'>" +
                         "</div>" +
                         "</div>" +
                         "</div>";
     TabTemplate       = "<div id='#{tabId}'>" +
                         "  <input type='hidden' name='#{current_field}[key]' id='#{scored_current_field}key' value='#{key}'/>" +
                         "  <table class='parameter'><tbody>" +
                         "    <tr>" +
                         "      <th>Key</th>" +
                         "      <th>Value</th>" +
                         "      <th></th>" +
                         "    </tr>" +
                         "  </tbody></table>" +
                         "  <a href='#' class='add_parameter' field_name=\"#{fields}\" onclick=\"return false;\">Add parameter</a>" +
                         "</div>",
     ParameterTemplate = "<tr class=\"parameter\"> " +
                         "  <td><input id='#{scored_field}_key' name='#{field}[][key]' size='#{size}' type='text' value='' #{disabled} /></td> " +
                         "  <td><input id='#{scored_field}_value' name='#{field}[][value]' size='#{size}'/></td> " +
                         "  <td><a class='#{scope_class}' href='#' onclick='return false;'>Convert to Scope</a><a class='remove' href='#' onclick=\"$(this).closest('tr').remove(); return false;\">Remove</a></td> " +
                         "</tr>",
     Tabs = $( ".tab_nav" ).tabs(),         // Normal Tab
     TabsAlt = $( ".tab_nav_alt" ).tabs();  // Vertical Tab

 TabsAlt.addClass( "ui-helper-clearfix" );
 $( ".tab_nav_alt li" ).removeClass( "ui-corner-top" ).addClass( "ui-corner-left" );
 function AddParameter(object) {
   var field        = $(object).attr('field_name'),
       size         = $(object).attr('size') || '30',
       disabled     = $(object).attr('disabled') || '';
   var scored_field = field.replace(/[\[|\]]/g, '_');
   var scope_class  = 'add_scope';
   if ($(object).parent('.ui-tabs-panel').parent('.ui-tabs').hasClass('tab_nav_alt')) {
   	  if ($(object).parent('.ui-tabs-panel').attr('id').match(/default/)) {
   	    scope_class = 'add_scope_alt';	
   	  }
   } else if ($(object).parent('.ui-tabs-panel').parent('.ui-tabs').hasClass('tab_nav')) {
   	 if (!($(object).parent('.ui-tabs-panel').attr('id').match(/default/))) {
   	 	scope_class = 'add_scope_alt';
   	 }
   }
   var parameter    = $(ParameterTemplate.replace(/#{scope_class}/g, scope_class).replace(/#{scored_field}/g, scored_field).replace(/#{field}/g, field).replace(/#{disabled}/g, disabled).replace(/#{size}/g, size));
  
   $(object).parent('.ui-tabs-panel').find('tbody').append(ApplyButtons(parameter));
 }

 function AddTab(object) {
   var current_fields = $(object).closest('tr').find("input:first").attr('name').replace(/\[key\]/g, ''),
       key            = $(object).closest('tr').find("input:first").val().toLowerCase(),   
       parentTabId    = $(object).parents(".ui-tabs-panel").attr('id'),
       tabClass       = 'tab_nav_alt';
   var parentTab      = $("#" + parentTabId),
       tabLabel       = key.charAt(0).toUpperCase() + key.slice(1),
       fields         = current_fields + "[parameters]",
       addTabId       = (parentTabId + "_" + key);
   // Conditionally alter certain variables
   if (parentTabId.match(/default/)) {                        // If we're in a default scope
   	 addTabId = (parentTabId + key).replace(/default/g, '');  // We need to cut off the default
   	 parentTab = parentTab.parent();                          // And traverse up one to get the actual container
   }
   // Alternate the class, we default to tab_nav_alt so we check for it and alter
   if (parentTab.parent().hasClass("tab_nav_alt")) { tabClass = 'tab_nav'; }
      
   // Validations - should probably do more than just stop doing anything
   if (key.length < 1) { return false; }                               // Need a key
   if (key == "default") { return false; }                             // Reserved for default scope
   if ($(document).find("#" + addTabId).length > 0) { return false; }  // Can't duplicate ids

   // Construct the templates   
   var tabBody        = $(TabTemplate.replace(/#{tabId}/g, addTabId).replace(/#{label}/g, tabLabel).replace(/#{fields}/g, fields).replace(/#{key}/g, key).replace(/#{current_field}/g, current_fields).replace(/#{scored_current_field}/g, current_fields.replace(/[\[|\]]/g, '_'))),
       tabHeader      = $(TabHeaderTemplate.replace(/#{tabId}/g, addTabId).replace(/#{label}/g, tabLabel));
   
   $(object).closest('tr').remove();
   //Check for the header and create it and a container for it if it doesn't exist
   if (parentTab.find('ul').length < 1) {
   	 var replace = $(CompleteTabHeader.replace(/#{parentTabId}/g, parentTabId).replace(/#{tab_class}/g, tabClass));
   	 replace.find('#' + parentTabId + "_default").append(parentTab.html());  // Insert the current content into the new div
   	 // Need to find the header, which will be in the parent and replace the link
   	 parentTab.parent().find('a[href=#'+parentTabId+']').attr('href', '#' + parentTabId + "_container");
   	 replace.find('ul').removeClass();
   	 replace.find('li').removeClass();
   	 parentTab.replaceWith(replace);
   	 // Need to redo the click
   	 parentTab = $("#" + parentTabId);
   	 parentTab.find("a.add_parameter").click(function(){AddParameter(this)}); 
   	 parentTab.tabs();  	 
   	 // Need to refresh the Tabs and TabsAlt variables
   	 if (tabClass == "tab_nav") { 
   	 	Tabs = $( ".tab_nav" );
   	 } else { 
   	 	TabsAlt = $( ".tab_nav_alt"); 
        TabsAlt.addClass( "ui-helper-clearfix" );
        $( ".tab_nav_alt li" ).removeClass( "ui-corner-top" ).addClass( "ui-corner-left" );
   	 }
   }
   
   parentTab.find('ul:first').append(tabHeader);
   parentTab.append(ApplyButtons(tabBody));
   
   Tabs.tabs("refresh");
   TabsAlt.tabs("refresh");
 }

 function ApplyButtons(object) {
   object.find( "a.add_parameter").button({ icons: { primary: "ui-icon-circle-plus"} }).click(function(){AddParameter(this);});
   object.find( "a.add_scope" ).button({ icons: { primary: "ui-icon-arrowreturnthick-1-n" }, text: false }).click(function(){AddTab(this);});
   object.find( "a.add_scope_alt").button({ icons: { primary: "ui-icon-arrowreturnthick-1-w" }, text: false }).click(function(){AddTab(this);});
   object.find( "a.remove" ).button({icons: { primary: "ui-icon-closethick"}, text: false});
   return object;
 }

 Tabs.delegate("span.ui-icon-close", "click", function(){
   var tabId = $(this).closest('li').remove().attr("aria-controls");
   $("#" + tabId).remove();
   Tabs.tabs("refresh");
 });
 
 TabsAlt.delegate("span.ui-icon-close", "click", function(){
   var tabId = $(this).closest('li').remove().attr("aria-controls");
   $("#" + tabId).remove();
   TabsAlt.tabs("refresh");
 });
 
 $( "a.remove" ).button({icons: { primary: "ui-icon-closethick"}, text: false});
 $( "a.add_parameter").button({ icons: { primary: "ui-icon-circle-plus"} }).click(function(){
   AddParameter(this);
 });
 $( "a.add_scope" ).button({ icons: { primary: "ui-icon-arrowreturnthick-1-n"}, text: false}).click(function(){
   AddTab(this);
 });
 $( "a.add_scope_alt").button({ icons: { primary: "ui-icon-arrowreturnthick-1-w"}, text: false }).click(function(){
   AddTab(this);
 }); 
});
