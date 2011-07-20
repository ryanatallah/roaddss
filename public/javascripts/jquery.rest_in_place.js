function RestInPlaceEditor(e) {
  this.element = jQuery(e);
  this.initOptions();
  this.bindForm();
  
  this.element.bind('click', {editor: this}, this.clickHandler);
}

RestInPlaceEditor.prototype = {
  // Public Interface Functions //////////////////////////////////////////////
  
  activate : function() {
    this.currency = $("#currency").html();
    if (this.currency == "USD") {
      this.oldValue = this.element.html().replace('$','').replace(/,/g,'');
    }
    if (this.currency == "GBP") {
      this.oldValue = this.element.html().replace('&pound;','').replace(/,/g,'');
    }
    if (this.currency == "EUR") {
      this.oldValue = this.element.html().replace('&euro;','').replace(/./g,'').replace(/,/g,'.');
    }
    if (this.currency == "CAD") {
      this.oldValue = this.element.html().replace('$','').replace(/,/g,'');
    }
    this.element.addClass('rip-active');
    this.element.closest('tr').addClass('edit-row');
    this.element.unbind('click', this.clickHandler);
    this.activateForm();
  },
  
  abort : function() {
    this.element
      .html(this.oldValue)
      .removeClass('rip-active')
      .bind('click', {editor: this}, this.clickHandler);
    this.element.closest('tr').removeClass('edit-row');
  },
  
  update : function() {
    var editor = this;
    editor.ajax({
      "type"       : "post",
      "data"       : editor.requestData(),
      "success"    : function(){
        editor.ajax({
          "dataType" : 'json',
          "success"  : function(data){ editor.loadSuccessCallback(data) }
        });
        editor.element.removeClass('rip-active');
        editor.element.closest('tr').removeClass('edit-row');
      }
    });
    editor.element.html("saving...");
  },
  
  activateForm : function() {
    alert("The form was not properly initialized. activateForm is unbound");
  },
  
  // Helper Functions ////////////////////////////////////////////////////////
  
  initOptions : function() {
    // Try parent supplied info
    var self = this;
    self.element.parents().each(function(){
      self.url           = self.url           || jQuery(this).attr("data-url");
      self.formType      = self.formType      || jQuery(this).attr("data-formtype");
      self.objectName    = self.objectName    || jQuery(this).attr("data-object");
      self.objectID      = self.objectID      || jQuery(this).attr("data-object-id");
      self.attributeName = self.attributeName || jQuery(this).attr("data-attribute");
    });
    // Try Rails-id based if parents did not explicitly supply something
    self.element.parents().each(function(){
      var res;
      if (res = this.id.match(/^(\w+)_(\d+)$/i)) {
        self.objectName = self.objectName || res[1];
      }
    });
    // Load own attributes (overrides all others)
    self.url           = self.element.attr("data-url")       || self.url      || document.location.pathname;
    self.formType      = self.element.attr("data-formtype")  || self.formtype || "input";
    self.objectName    = self.element.attr("data-object")    || self.objectName;
    self.objectID      = self.element.attr("data-object-id") || self.objectID;
    self.attributeName = self.element.attr("data-attribute") || self.attributeName;
  },
  
  bindForm : function() {
    this.activateForm = RestInPlaceEditor.forms[this.formType].activateForm;
    this.getValue     = RestInPlaceEditor.forms[this.formType].getValue;
  },
  
  getValue : function() {
    alert("The form was not properly initialized. getValue is unbound");    
  },
  
  /* Generate the data sent in the POST request */
  requestData : function() {
    //jq14: data as JS object, not string.
    var data = "_method=put";

    var object = this.objectName.replace( /\]$/, "_attributes]" );
    data += "&" + object + "[" + this.attributeName + "]=" + encodeURIComponent(this.getValue());

    if ( this.objectID ) {
        data += "&" + object + "[id]=" + encodeURIComponent(this.objectID);
    }

    if (window.rails_authenticity_token) {
      data += "&authenticity_token="+encodeURIComponent(window.rails_authenticity_token);
    }
    return data;
  },
  
  ajax : function(options) {
    options.url = this.url;
    return jQuery.ajax(options);
  },

  // Handlers ////////////////////////////////////////////////////////////////
  
  loadSuccessCallback : function(data) {
    //jq14: data as JS object, not string.
    if (jQuery.fn.jquery < "1.4") data = eval('(' + data + ')' );

    // Check for nested models
    if ( typeof data[this.objectName] !== "undefined" ) {
        this.element.html(data[this.objectName][this.attributeName]);
    } else {
        var parts = this.objectName.match( /(.+)\[(.+)\]/ );
        this.element.html(data[parts[1]][parts[2]][this.attributeName]);
    }

    this.element.bind('click', {editor: this}, this.clickHandler);    
  },
  
  clickHandler : function(event) {
    event.data.editor.activate();
  }
};


RestInPlaceEditor.forms = {
  "input" : {
    /* is bound to the editor and called to replace the element's content with a form for editing data */
    activateForm : function() {
      this.element.html('<form action="javascript:void(0)" style="display:inline;"><input type="text" value="' + jQuery.trim(this.oldValue) + '"></form>');
      this.element.find('input')[0].select();
      this.element.find("form")
        .bind('submit', {editor: this}, RestInPlaceEditor.forms.input.submitHandler);
      this.element.find("input")
        .bind('blur',   {editor: this}, RestInPlaceEditor.forms.input.inputBlurHandler);
    },
    
    getValue :  function() {
      return this.element.find("input").val();
    },

    inputBlurHandler : function(event) {
      event.data.editor.abort();
    },

    submitHandler : function(event) {
      event.data.editor.update();
      return false;
    }
  },

  "textarea" : {
    /* is bound to the editor and called to replace the element's content with a form for editing data */
    activateForm : function() {
      this.element.html('<form action="javascript:void(0)" style="display:inline;"><textarea>' + jQuery.trim(this.oldValue) + '</textarea></form>');
      this.element.find('textarea')[0].select();
      this.element.find("textarea")
        .bind('blur', {editor: this}, RestInPlaceEditor.forms.textarea.blurHandler);
    },
    
    getValue :  function() {
      return this.element.find("textarea").val();
    },

    blurHandler : function(event) {
      event.data.editor.update();
    }

  }
};

jQuery.fn.rest_in_place = function() {
  this.each(function(){
    jQuery(this).data('restInPlaceEditor', new RestInPlaceEditor(this));
  })
  return this;
};