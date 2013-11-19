// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
var last = 0;

function htmlEncode(value) {
	return value;
}

function updateMessages() {
	$.getJSON('/messages.json', function(data) {
		if (data.length == 0 && last == 0) {
			$(".messages").html("<h3>Nothing to display...</h3>").hide().fadeIn("slow");
		}
		else if (data.length > last) {
			if (last == 0) {
				$(".messages").html("");
			}
			for (i = last; i < data.length; i++) {
			    $(".messages").prepend('<div class="message" style="background-color : blue; color: white"><p class="content">' + htmlEncode(data[i]["content"]) + '</p><p class="username">' + htmlEncode(data[i]["username"]) + ', <a href="messages/' + data[i]["id"] + '" style="color: white">' + jQuery.timeago(data[i]["created_at"]) + '</a></p></div>').hide().fadeIn("slow");
				last++;
			}
		}
	});
	
	setTimeout(updateMessages, 30000);
}

$(document).ready(function() {
	updateMessages();
});