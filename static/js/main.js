var currentPage;

$(document).ready(function () {
    $.ajax({
        url: "config.json",
        success: function(configData) {
            initNavigation(configData);
            currentPage = configData["pages"][0]["name"];
            initModules(configData["pages"][0]);
        },
        error: function() {
            let content = $("#content");
            let message = `
                <div class='col-md-6 col-md-offset-3'>
                    <div class='alert alert-danger text-center'>Error while loading the configuration file!</div>
                </div>
            `;
            content.empty();
            content.append(message);
        }
    });
});

function initNavigation(configData) {
    let navigation = $("#navigation");
    navigation.empty();
    $.each(configData["pages"], function (i, pageData) {
        let item = $("<li><a>" + pageData["name"] + "</a></li>");
        item.click(function() {
            currentPage = pageData["name"];
            initModules(pageData);
        });
        navigation.append(item);
    });
}

function initModules(pageData) {
    let pageContent = $("#content");
    pageContent.empty();

    let pageName = pageData["name"];
    $.each(pageData["modules"], function (i, moduleData) {
        switch (moduleData.template) {
            case "KeyValue":
                initKeyValueModule(pageName, moduleData, pageContent);
                break;
            case "Table":
                initTableModule(pageName, moduleData, pageContent);
                break;
            case "Graph":
                initGraphModule(pageName, moduleData, pageContent);
                break;
            case "BarChart":
                initBarChartModule(pageName, moduleData, pageContent);
        }
    });
}

function initModule(pageName, moduleData, pageContent, buttonEnabled, loadingAnimation, refreshInterval, onInitModule, onAjaxSuccess) {
    let moduleTemplate = getModuleTemplate(moduleData["header"], moduleData["name"], buttonEnabled);
    pageContent.append(moduleTemplate);
    let moduleContent = $("#module-body-" + moduleData["name"]);

    if (buttonEnabled) {
        $("#module-button-" + moduleData["name"]).click(requestModuleData);
    }

    onInitModule(moduleContent);

    function requestModuleData() {
        if (loadingAnimation) {
            moduleContent.empty();
            moduleContent.append("<img class='loading' src='static/img/loading.svg' />")
        }
        $.ajax({
            url: "module",
            method: "POST",
            data: { name: moduleData["name"] + moduleData["ending"] },
            success: function (responseData) {
                if (jQuery.isEmptyObject(responseData)) {
                    moduleContent.empty();
                    moduleContent.append("<div class='alert alert-info text-center'>No data available!</div>");
                }
                else {
                    if (loadingAnimation) {
                        moduleContent.empty();
                    }
                    onAjaxSuccess(responseData, moduleContent);
                    $("#module-time-" + moduleData["name"]).text("(" + getCurrentTimeFormat() + ")");
                }
                if (refreshInterval > 0 && pageName == currentPage) {
                    setTimeout(requestModuleData, refreshInterval);
                }
            },
            error: function() {
                moduleContent.empty();
                moduleContent.append("<div class='alert alert-danger text-center'>Error while loading the module!</div>");
                if (refreshInterval > 0 && pageName == currentPage) {
                    setTimeout(requestModuleData, refreshInterval);
                }
            }
        });
    }
    requestModuleData();
}

function initKeyValueModule(pageName, moduleData, pageContent) {
    let onInitModule = function(moduleContent) {};

    let onAjaxSuccess = function(responseData, moduleContent) {
        let body = "<tbody>";
        $.each(responseData, function (key, value) {
            body += "<tr><th>" + key + "</th><td>" + value + "</td></tr>";
        });
        body += "</tbody>";

        let table = "<table class='table table-striped table-bordered'>";
        table += body;
        table += "</table>";

        moduleContent.append(table);
    };

    initModule(pageName, moduleData, pageContent, true, true, 0, onInitModule, onAjaxSuccess);
}

function initTableModule(pageName, moduleData, pageContent) {
    let onInitModule = function(moduleContent) {};

    let onAjaxSuccess = function(responseData, moduleContent) {
        let head = "<thead><tr>";
        $.each(responseData[0], function(key) {
            head += "<th>" + key + "</th>";
        });
        head += "</tr></thead>";

        let body = "<tbody>";
        $.each(responseData, function(i, val) {
            let row = "<tr>";
            $.each(val, function(key, value) {
                row += "<td>" + value + "</td>";
            });
            row += "</tr>";
            body += row;
        });
        body += "</tbody>";

        let table = "<table class='table table-striped table-bordered'>";
        table += head;
        table += body;
        table += "</table>";

        table = $(table).tablesorter();
        moduleContent.append(table);
    };

    initModule(pageName, moduleData, pageContent, true, true, 0, onInitModule, onAjaxSuccess);
}

function initGraphModule(pageName, moduleData, pageContent) {
    let options = {
        series: {
            lines: { show: true },
            points: { show: true }
        },
        xaxis: {
            ticks: 10,
            tickSize: 1
        },
        yaxis: {
            min: 0,
            max: moduleData["max"]
        },
        grid: {
            borderWidth: 1,
            borderColor: "#dddddd",
            color: "#333333",
            hoverable: true
        },
        legend: {
            position: "nw",
            margin: 20
        }
    };

    let i = 0;
    let j = 10;
    let d = [];
    let plot = {};

    let onInitModule = function(moduleContent) {
        plot = $.plot(moduleContent, d, options);
        addTooltipToModule(moduleContent);
    };

    let onAjaxSuccess = function(responseData, moduleContent) {
        i++;
        $.each(responseData, function (index, obj) {
            let label = obj[Object.keys(obj)[0]];
            let value = obj[Object.keys(obj)[1]];

            if (i == 1) {
                d.push({label: label, data: [[i, value]]})
            }
            else {
                d[index]["data"].push([i, value]);
            }

            if (j == 0) {
                d[index]["data"].shift();
            }
        });

        if (j > 0) j--;

        plot.setData(d);
        plot.setupGrid();
        plot.draw();
    };
    initModule(pageName, moduleData, pageContent, false, false, moduleData["refresh"], onInitModule, onAjaxSuccess);
}

function initBarChartModule(pageName, moduleData, pageContent) {
    let onInitModule = function(moduleContent) {};

    let onAjaxSuccess = function(responseData, moduleContent) {
        let d = [];
        $.each(responseData, function (index, obj) {
            let x = obj[Object.keys(obj)[0]];
            let y = obj[Object.keys(obj)[1]];
            d.push([x, y]);
        });

        let options = {
            series: {
                bars: {
                    show: true,
                    align: "center",
                    barWidth: 0.8,
                    fill: true
                }
            },
            xaxis: {
                mode: "categories",
                tickLength: 0
            },
            yaxis: {
                min: 0
            },
            grid: {
                borderWidth: 1,
                borderColor: "#dddddd",
                color: "#333333",
                hoverable: true
            }
        };

        $.plot(moduleContent, [{color: "#337ab7", data: d}], options);
        addTooltipToModule(moduleContent);
    };

    initModule(pageName, moduleData, pageContent, true, true, 0, onInitModule, onAjaxSuccess);
}

function getModuleTemplate(title, name, button = true) {
    const template = `
         <div class="col-md-6">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <b>{{title}}</b>
                    <span id="module-time-{{name}}">({{time}})</span>
                    <button id="module-button-{{name}}" style="visibility: {{visibility}}" type="button" class="btn btn-default btn-xs pull-right">
                        <span class="glyphicon glyphicon-refresh"></span>
                    </button>
                </div>
                <div id="module-body-{{name}}" class="panel-body scroll"></div>
            </div>
        </div>
    `;
    let visibility = button ? "visible" : "hidden";
    return template
        .replace(/\{\{title}}/g, title)
        .replace(/\{\{name}}/g, name)
        .replace(/\{\{visibility}}/g, visibility)
        .replace(/\{\{time}}/g, getCurrentTimeFormat());
}

function getCurrentTimeFormat() {
    function appendTimeComponent(format, component, separator = true) {
        if (component < 10) {
            format += "0" + component;
        }
        else {
            format += component;
        }
        if (separator) {
            format += ":";
        }
        return format;
    }

    let date = new Date();
    let format = appendTimeComponent("", date.getHours());
    format = appendTimeComponent(format, date.getMinutes());
    return appendTimeComponent(format, date.getSeconds(), false);
}

function addTooltipToModule(moduleContent) {
    $(moduleContent).bind("plothover", function (event, pos, item) {
        let tooltip = $("#hoverbox");
        if (item) {
            let text = item.datapoint[1].toFixed(2);
            tooltip.html(text);
            let top = item.pageY - 5 - (tooltip.height() * 2);
            let left = item.pageX - 5 - Math.ceil(tooltip.width() / 2);
            tooltip.css({top: top, left: left}).show();
        }
        else {
            tooltip.hide();
        }
    });
}

function clearAllTimeouts() {
    for (let i = 0; i < timeouts.length; i++) {
        clearTimeout(timeouts.pop());
    }
}
