
$(function () {
    var bundle = getQueryVariable('p');

    if (bundle != undefined) {
        //Now fetch the appropriate file from this query string
    }


    console.log(getQueryVariable('p'));
    console.log("Fetching XML");
    var getUrl = window.location;
    var baseUrl = getUrl.protocol + "//" + getUrl.host + "/" + getUrl.pathname.split('/').slice(0, -1);
    console.log(baseUrl + "/files/" + bundle + "/info.xml");

    $.ajax({
        type: "GET",
        url: baseUrl + "/" + bundle + "/info.xml",
        dataType: "xml",
        success: function (xml) {
            console.log("Beginning XML Parsing");

            // Parse the xml file and get data
            $(xml).find('packageInfo').each(function () {
                document.getElementById("packageTitle").innerHTML = $(this).find("name").text();
                document.getElementById("bundleId").innerHTML = $(this).find("bundleId").text();
                document.getElementById("Compatibility").innerHTML = $(this).find("miniOS").text() + '-' + $(this).find("maxiOS").text();
                document.getElementById("icon").innerHTML = '<img src="' + bundle + '/' + $(this).find("icon").text() + '" style="vertical-align: middle" width="70" height="70"/>';

                $(xml).find('description').each(function () {
                    $("#description").append('<p>' + $(this).text() + '</p>');
                });

                $(xml).find('dependency').each(function () {
                    $("#dependencies").append('<p>' + $(this).text() + '</p>');
                });

                $(xml).find('linkName').each(function () {
                    $("#links").append('<p>' + $(this).text() + '</p>');
                });

                $(xml).find('change').each(function () {
                    $("#changeLog").append('<p>' + '<h2>' + $(this).find("changeVersion").text() + '</h2>' + '</p>');
                    $(this).find('changeDescription').each(function () {
                        $("#changeLog").append('<p>' + $(this).text() + '</p>');
                    });
                });

                $(xml).find('screenshot').each(function () {
                    $("#screenshots").append('<img src="' + bundle + '/screenshots/' + $(this).text() + '" data-toggle="modal" width="250px">');
                });
            });
        }
    });
});


function getQueryVariable(variable) {
    var query = window.location.search.substring(1);
    var vars = query.split('&');
    for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split('=');
        if (decodeURIComponent(pair[0]) == variable) {
            return decodeURIComponent(pair[1]);
        }
    }
    console.log('Query variable %s not found', variable);
}
