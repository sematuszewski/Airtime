var TemplateManager = {
    templates: {},

    get: function(id, callback){
        var template = this.templates[id];
        if (template) {
          callback(template);
        
        } else {
        
          var that = this;
          $.get(baseUrl+"/Template/" + id, function(template){
                var $tmpl = template;
                that.templates[id] = $tmpl;
                callback($tmpl);
            });
        }
    }
}

/*var UserRouter = Backbone.Router.extend({
    routes: {
        "": "index"
    },
    
    index: function() {
    }
})

var router = new UserRouter();
//Backbone.history.start();*/

var UserModel = Backbone.Model.extend({
    urlRoot: '/user-rest',
    initialize: function(){
    },
    defaults: {
        id: undefined,
        login: "",
        password: "",
        first_name: "",
        last_name: "",
        email: "",
        cell_phone: "",
        skype_contact: "",
        jabber_contact: "",
        type: "G"
    },
    validation:{
        login: {
            required: true
        },
        email: {
            required: true,
            pattern: 'email'
        },
        password: {
            required: true
        },
        jabber_contact: {
            required: false,
            pattern: 'email'
        }
    }
})

var UserView = Backbone.View.extend({
    template: 'userForm',
    initialize: function(){
        this.render();
        this.model.bind("change", this.render, this);
    },
    events: {
        "click #save_user": "submitForm",
    },
    render: function(){
        var that = this;
        TemplateManager.get(this.template, function(template){
            var compiled = _.template(template);
            var html = compiled(that.model.toJSON());
            that.$el.html(compiled(that.model.toJSON()));
            that.$el.find("#type").val(that.model.get('type'));
            if (that.model.get("id") == undefined) {
                that.$el.find("#password").val("");
            } else {
                that.$el.find('#login').attr('readonly', 'readonly');
                that.$el.find("#password").val("xxxxxx");
                that.model.set("password", "xxxxxx");
            }
            // remove all error msg
            that.$el.find(".rest-errors").remove();
        });
        return this;
    },
    removeUser: function(id){
        this.model.set('id', id);
        this.model.destroy();
    },
    submitForm: function(){
        // remove all error msg
        this.$el.find(".rest-errors").remove();
        
        Backbone.Validation.bind(this, {
            valid: function(view, attr, selector){
                
            },
            invalid: function(view, attr, error, selector){
                control = view.$('[' + selector + '=' + attr + ']');
                group = control.parents("dd");
                group.append("<div class='rest-errors'>"+error+"</div>");
            }
        });
        var temp = this.$el.find('#user_form').serializeArray();
        var formData = {};
        $.each(temp, function(i, v){
            formData[temp[i].name] = temp[i].value;
        })
        _.extend(Backbone.Validation.messages, {
            required: $.i18n._("Value is required and can't be empty"),
            pattern: $.i18n._("Value is not a valid email address in the basic format local-part@hostname")
        });
        if (this.model.set(formData)) {
            this.model.save(this.model.toJSON(), {
                success: function(){
                    $('#users_datatable').dataTable().fnDraw();
                    $("#user_form").prepend("<div class='success'>User updated successfully!</div>");
                    setTimeout(removeSuccessMsg, 5000);
                },
                error: function(model, response){
                    var error = $.parseJSON(response.responseText);
                    $.each(error, function(i, v){
                        selector = 'name';
                        control = $('[' + selector + '=' + i + ']');
                        group = control.parents("dd");
                        group.append("<div class='rest-errors'>"+v+"</div>");
                    })
                },
            });
        }
        Backbone.Validation.unbind(this);
    }
})

var DTView = Backbone.View.extend({
    initialize: function(){
        this.render();
    },
    render: function(){
        $(this.el).dataTable( {
            "bProcessing": true,
            "bServerSide": true,
            "sAjaxSource": baseUrl+"/User/get-user-data-table-info/format/json",
            "fnServerData": function ( sSource, aoData, fnCallback ) {
                $.ajax( {
                    "dataType": 'json', 
                    "type": "POST", 
                    "url": sSource, 
                    "data": aoData, 
                    "success": fnCallback
                } );
            },
            "fnRowCallback": rowCallback,
            "aoColumns": [
                /* Id */         { "sName": "id", "bSearchable": false, "bVisible": false, "mDataProp": "id" },
                /* user name */  { "sName": "login", "mDataProp": "login" },
                /* first name */ { "sName": "first_name", "mDataProp": "first_name" },
                /* last name */  { "sName": "last_name", "mDataProp": "last_name" },
                /* user type */  { "sName": "type", "bSearchable": false, "mDataProp": "type" },
                /* del button */ { "sName": "null as delete", "bSearchable": false, "bSortable": false, "mDataProp": "delete"}
            ],
            "bJQueryUI": true,
            "bAutoWidth": false,
            "bLengthChange": false,
            "oLanguage": datatables_dict,
            
            "sDom": '<"H"lf<"dt-process-rel"r>>t<"F"ip>',
        });
        return this;
    }
})

var user = new UserModel();

function rowClickCallback(row_id){
    user.set("id",row_id);
    user.fetch();
}

function removeUserCallback(row_id, nRow){
    var current_id = user.get('id');
    user.set('id', row_id);
    user.destroy({
        success: function(){
        },
        error: function(){
        }
    });
    user.set('id', current_id);
    var o = $('#users_datatable').dataTable().fnDeleteRow(nRow);
}

function rowCallback( nRow, aData, iDisplayIndex ){
    $(nRow).click(function(){rowClickCallback(aData['id'])});
    if( aData['delete'] != "self"){
    	$('td:eq(4)', nRow).append( '<span class="ui-icon ui-icon-closethick"></span>').children('span').click(function(e){e.stopPropagation(); removeUserCallback(aData['id'], nRow)});
    }else{
    	$('td:eq(4)', nRow).empty().append( '<span class="ui-icon ui-icon-closethick"></span>').children('span').click(function(e){e.stopPropagation(); alert("Can't delete yourself!")});
    }

    if ( aData['type'] == "A" )
    {
	    $('td:eq(3)', nRow).html( $.i18n._('Admin') );
    } else if ( aData['type'] == "H" )
    {
	    $('td:eq(3)', nRow).html( $.i18n._('DJ') );
    } else if ( aData['type'] == "G" )
    {
	    $('td:eq(3)', nRow).html( $.i18n._('Guest') );
    } else if ( aData['type'] == "P" )
    {
    	$('td:eq(3)', nRow).html( $.i18n._('Program Manager') );
    }
    
    return nRow;
}

$(document).ready(function() {
    var userView = new UserView({el: $("#user_details"), model: user });
    var dtView = new DTView({el: $("#users_datatable")});
    
    $('#add_user_button').live('click', function(){
        user.set(user.defaults);
    });
    
});
