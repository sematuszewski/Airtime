
function populateForm(entries){
    //$('#user_details').show();
        
    $('.errors').remove();
    $('.success').remove();
    
    $('#user_id').val(entries.id);
    $('#login').val(entries.login);
    $('#first_name').val(entries.first_name);
    $('#last_name').val(entries.last_name);
    $('#type').val(entries.type);
    $('#email').val(entries.email);
    $('#cell_phone').val(entries.cell_phone);
    $('#skype').val(entries.skype_contact);
    $('#jabber').val(entries.jabber_contact);
    
    if (entries.id.length != 0){
        $('#login').attr('readonly', 'readonly');
        $('#password').val("xxxxxx");
    } else {
        $('#login').removeAttr('readonly');
        $('#password').val("");
    }
}

function rowClickCallback(row_id){
      $.ajax({ url: baseUrl+'/User/get-user-data/id/'+ row_id +'/format/json', dataType:"json", success:function(data){
        populateForm(data);
	  }});    
}

function removeUserCallback(row_id, nRow){
      $.ajax({ url: baseUrl+'/User/remove-user/id/'+ row_id +'/format/json', dataType:"text", success:function(data){
        var o = $('#users_datatable').dataTable().fnDeleteRow(nRow);
	  }});
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

function populateUserTable() {
    $('#users_datatable').dataTable( {
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
}

$(document).ready(function() {
 // backbone stuff start


    var TemplateManager = {
        templates: {},

        get: function(id, callback){
            var template = this.templates[id];
            if (template) {
              callback(template);
            
            } else {
            
              var that = this;
              $.get(baseUrl+"/js/backbone/templates/" + id + ".html", function(template){
                    var $tmpl = template;
                    that.templates[id] = $tmpl;
                    callback($tmpl);
                });
            }
        }
    }


    var UserRouter = Backbone.Router.extend({
        routes: {
            "": "index"
        },
        
        index: function() {
        }
    })

    var router = new UserRouter();
    Backbone.history.start();

    var UserModel = Backbone.Model.extend({
        url: function() {
            return '/User/get-user-data/id/'+this.id+'/format/json';
        },
        initialize: function(){
            
        },
        defaults: {
            id: 0,
            login: ""
        }
    })

    var UserView = Backbone.View.extend({
        template: 'user/userForm',
        initialize: function(){
            var that = this;
            this.model.fetch({
                success: function(user){
                    that.render();
                }
            });
        },
        render: function(){
            var that = this;
            TemplateManager.get(this.template, function(template){
                var compiled = _.template(template);
                var html = compiled(that.model.toJSON());
                that.$el.html(compiled(that.model.toJSON()));
                that.$el.find("#type").val(that.model.get('type'));
            });
            return this;
        }
    })
    
    var user = new UserModel({id:1});

    var userView = new UserView({el: $("#user_details"), model: user });

    //backbone stuff end
    
    
    
    
    
    populateUserTable();
    
    //$('#user_details').hide();
    
    var newUser = {login:"", first_name:"", last_name:"", type:"G", id:""};
    
    $('#add_user_button').live('click', function(){populateForm(newUser)});
    
    $('#save_user').live('click', function(){
        var data = $('#user_form').serialize();
        var url = baseUrl+'/User/add-user';
        
        $.post(url, {format: "json", data: data}, function(data){
            var json = $.parseJSON(data);
            if (json.valid === "true") {
                $('#content').empty().append(json.html);
                populateUserTable();
            } else {
                //if form is invalid we only need to redraw the form
                $('#user_form').empty().append($(json.html).find('#user_form').children());
            }
            setTimeout(removeSuccessMsg, 5000);
        });
    });
    
});
