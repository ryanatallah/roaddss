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
    this.oldValueF = this.element.html();
    this.no_format = this.element.hasClass("no_format");
    this.ccyVar = false;

    if (this.no_format == false) {
      if (this.currency == "USD" || this.currency == "CAD") {
        if (this.oldValueF.search(/\u0024/) != '-1') {
          this.ccyVar = true;
          this.ccySymb = "$";
        }
        this.oldValue = this.element.html().replace(/\u0024/,'').replace(/,/g,'');
      }
      if (this.currency == "GBP") {
        if (this.oldValueF.search(/\u00a3/) != '-1') {
          this.ccyVar = true;
          this.ccySymb = "&pound;";
        }
        this.oldValue = this.element.html().replace(/\u00a3/,'').replace(/,/g,'');
      }
      if (this.currency == "EUR") {
        if (this.oldValueF.search(/\u20ac/) != '-1') {
          this.ccyVar = true;
          this.ccySymb = "&euro;";
        }
        this.oldValue = this.element.html().replace(/\u20ac/,'').replace(/\./g,'').replace(/,/g,'.');
      }
    } else {
      this.oldValue = this.element.html();
    }
    this.decimals = decimalCounter(this.oldValue);
    this.element.addClass('rip-active');
    this.element.closest('tr').addClass('edit-row');
    this.element.unbind('click', this.clickHandler);
    this.activateForm();
  },

  abort : function() {
    this.element
      .html(this.oldValueF)
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
        this.newVal = data[this.objectName][this.attributeName]
    } else {
        var parts = this.objectName.match( /(.+)\[(.+)\]/ );
        this.newVal = data[parts[1]][parts[2]][this.attributeName]
    }

    alert("gate 1");

    if (this.no_format == false) {
      alert("gate 2a");
      this.element.html(addCommas(this.newVal, this.decimals));
      
      if (this.ccyVar) {
        alert("gate 2a1");
        this.element.prepend(this.ccySymb);
      }
    } else {
      alert("gate 2b");
      this.element.html(this.newVal, this.decimals);
    }

    alert("gate 3");
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

function decimalCounter(num) {
  var x = num.split('.');
  var count = x.length > 1 ? x[1].length : 0;
  return count;
}

function addCommas(nStr, decimals) {
  var ccy = $("#currency").html();
  var delimitor = ",";
  var separator = ".";
  if (ccy == "EUR") {
    delimitor = ".";
    separator = ",";
  }
  nStr += '';
  var x = nStr.split('.');
  var x1 = x[0];

  if (decimals == 0) {
    var x2 = '';
  } else if (decimals == 1) {
    var x2 = separator + x[1].substr(0.1);
  } else {
    var x2 = x[1].length > 1 ? separator + x[1].substr(0,2) : separator + x[1] + '0';
  }
  var rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + delimitor + '$2');
  }
  return x1 + x2;
}