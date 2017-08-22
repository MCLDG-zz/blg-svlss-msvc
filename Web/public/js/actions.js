var post_bookings = function(event) {
  var data = {
      first_name: $("form input[name=first_name]").val(),
      last_name: $("form input[name=last_name]").val(),
      from_airport: $("form select[name=from_airport]").val(),
      to_airport: $("form select[name=to_airport]").val(),
      booking_class: $("form select[name=booking_class]").val(),
      departure_date: $("form input[name=departure_date]").val(),
      return_date: $("form input[name=return_date]").val(),
      age_group: $("form select[name=age_group]").val()
  };
  var output = $("#form-output-global");
  console.log(data);
  // Submit Bookings
  $.ajax({
    url : "/bookings",
    type: "POST",
    data: JSON.stringify(data),
    contentType: "application/json; charset=utf-8",
    dataType   : "json",
    success    : function(data, textStatus, xhr){
      console.log("Booking Submit Success");
      output.html('<p class="snackbars-left"><span class="icon icon-xxs mdi mdi-alert-outline text-middle"></span><span>Booking Success. Booking Number: ' + xhr.responseText + '</span></p>');
      output.addClass("success active");
      reload_bookings();
    },
    error      : function (xhr, ajaxOptions, thrownError) {
      console.log("Booking Submit Failed");
      output.html('<p class="snackbars-left"><span class="icon icon-xxs mdi mdi-alert-outline text-middle"></span><span>Booking Failed. Error: ' + xhr.responseText + '</span></p>');      
      output.addClass("error active");
      
    }
  });
  event.preventDefault();
};

var reload_bookings = function() {
  var tbody = $('#bookings-table tbody');
  tbody.empty();

  $.get(
    '/bookings',
    function(data, textStatus, jqXHR) {
      var bookings = data.data;
      for(b in bookings) {
        console.log(bookings[b]);
        get_airmiles_by_booking(bookings[b], function(booking, airmiles){
          console.log("appending rows :" + booking.booking_number);
          tbody.append("<tr>" + "<td>" + booking.booking_number  + "</td>" +
                       "<td>" + booking.first_name  + " " + booking.last_name  + "</td>" +
                       "<td>" + booking.from_airport + "</td>" +
                       "<td>" + booking.to_airport + "</td>" +
                       "<td>" + booking.departure_date + "</td>" +
                       "<td>" + booking.return_date + "</td>" +
                       "<td>" + booking.age_group + "</td>" +
                       "<td>" + booking.booking_class + "</td>" +
                       "<td>" + airmiles + "</td>" +
                       "</tr>");
        });
      }
    },
    'json'
  );
};

var get_airmiles_by_booking = function(booking, callback) {
  $.get(
    '/airmiles/' + booking.booking_number,
    function(data, textStatus, jqXHR) {
      console.log(data);
      var item = data.data;
      airmiles = (item.airmiles == undefined)? "N/A" : item.airmiles.N;
      console.log("Airmiles: " + airmiles);
      callback(booking, airmiles);
    },
    'json'
  ).fail(function(){
    console.log("WARNING: Airmile API GET mileages failed");
    callback(booking, "N/A");
  });
};
