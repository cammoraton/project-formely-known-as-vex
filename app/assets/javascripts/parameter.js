function AddParameter(object) {
  var ParameterTemplate = "<p class=\"parameter\"> " +
                          "  <span class=\"key\"><input id='#{scored_field}_key' name='#{field}[][key]' size='#{size}' type='text' value=''/></span> " +
                          "  <span class=\"value\"><input id='#{scored_field}_value' name='#{field}[][value]' size='#{size}'/></span> " +
                          "  <span class=\"actions\">" +
                          "    <a class='hash' href='#' onclick=\"HashParameter(this); return false;\">Convert to Hash</a>" +
                          "    <a class='remove' href='#' onclick=\"$(this).parents('.parameter').remove(); return false;\">Remove</a>" +
                          "  </span>" +
                          "</p>";
  var field        = $(object).attr('field_name'),
      size         = $(object).attr('size') || '30';
  var scored_field = field.replace(/[\[|\]]/g, '_');
  var parameter    = $(ParameterTemplate.replace(/#{scored_field}/g, scored_field).replace(/#{field}/g, field).replace(/#{size}/g, size));
  if ($(object).closest('.parameter_container').children('.nested_parameter').length) {
    $(object).closest('.parameter_container').children('.nested_parameter').before(parameter);
  } else {
    $(object).before(parameter);
  }
}

function HashParameter(object) {
  var NestedParameterTemplate = "<p class=\"parameter\">" +
                                "  <span class=\"key\">" +
                                "     <input id='#{scored_field}_key' name='#{field}[][key]' type='text' value='#{key}' disabled='disabled'/>" + 
                                "     <input id='#{scored_field}_key' name='#{field}[][key]' type='hidden' value='#{key}'/>" +
                                "  </span>" +
                                "  <span class='actions'>" +
                                "    <a class='unhash' href='#' onclick=\"UnHashParameter(this); return false;\">Unhash</a>" +
                                "    <a class='remove' href='#' onclick=\"$(this).parents('.parameter').next('.parameter_container').remove(); $(this).parents('.parameter').remove(); return false;\">Remove</a>" +
                                "  </span>" +
                                "</p>" +
                                "<div class=\"indent parameter_container\">" +
                                "  <div class=\"nested_parameter\">" +
                                "  </div>" +
                                "  <a class='add_parameter' href='#' onclick=\"AddParameter(this); return false;\" field_name='#{field}[][parameters]'>Add Parameter</a>" +
                                "</div>";
  var key              = $(object).closest(".parameter").find("span.key").find("input").val(),
      raw_field        = $(object).closest(".parameter").find("span.key").find("input").attr("name");
  if (key && key.length) {
    var field            = raw_field.replace(/\[\]\[key\]/, '');
    var scored_field     = field.replace(/[\[|\]]/g, '_');
    var nested_parameter = $(NestedParameterTemplate.replace(/#{key}/g, key).replace(/#{scored_field}/g, scored_field).replace(/#{field}/g, field));
    if ($(object).closest('.parameter_container').children('.nested_parameter').length) {
      $(object).closest('.parameter_container').children('.nested_parameter').append(nested_parameter);
      $(object).closest('.parameter').remove();
    }  
  }              
}

function UnHashParameter(object) {
  var ParameterTemplate = "<p class=\"parameter\"> " +
                          "  <span class=\"key\"><input id='#{scored_field}_key' name='#{field}[][key]' size='#{size}' type='text' value='#{key}'/></span> " +
                          "  <span class=\"value\"><input id='#{scored_field}_value' name='#{field}[][value]' size='#{size}'/></span> " +
                          "  <span class=\"actions\">" +
                          "    <a class='hash' href='#' onclick=\"HashParameter(this); return false;\">Convert to Hash</a>" +
                          "    <a class='remove' href='#' onclick=\"$(this).parents('.parameter').remove(); return false;\">Remove</a>" +
                          "  </span>" +
                          "</p></div>";
  var key              = $(object).closest(".parameter").find("span.key").find("input").val(),
      field            = $(object).closest(".parameter").find("span.key").find("input").attr("name"),AddParameter
      size             = $(object).attr('size') || '30';
  var scored_field = field.replace(/[\[|\]]/g, '_');
  var parameter    = $(ParameterTemplate.replace(/#{scored_field}/g, scored_field).replace(/#{field}/g, field).replace(/#{size}/g, size).replace(/#{key}/g, key));
  if (key && key.length) {
  	$(object).closest('.parameter').closest('.parameter_container').children('.nested_parameter').before(parameter);
  	$(object).closest('.parameter').next('.parameter_container').remove();
  	$(object).closest('.parameter').remove();
  }     
  
  return false;
}

