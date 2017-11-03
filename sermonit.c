#include <stdlib.h>
#include <stdio.h>

#include "mongoose.h"

const char *port = "8000";
const char *modulesdir = "modules";
struct mg_serve_http_opts opts;

void set_default_header(struct mg_connection *connection)
{
    mg_printf(connection, "%s", "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nTransfer-Encoding: chunked\r\n\r\n");
}

void set_error_response(struct mg_connection *connection)
{
    mg_printf_http_chunk(connection, "\r\n");
}

void set_module_data(struct mg_connection *connection, const char *name)
{
    FILE *pipe = NULL;
    char *line = NULL;
    char *file = NULL;
    size_t n = 0;

    n = strlen(modulesdir) + strlen(name) + 4;
    file = calloc(n, sizeof(char));
    snprintf(file, n, "./%s/%s", modulesdir, name);
    pipe = popen(file, "r");
    n = 0;

    if (pipe != NULL) {
        ssize_t read = getline(&line, &n, pipe);
        if (read > 0)
            mg_printf_http_chunk(connection, line);
        else
            set_error_response(connection);
        free(line);
        pclose(pipe);
    } else {
        set_error_response(connection);
    }
    free(file);
}

void handle_module(struct mg_connection *connection, struct http_message *message)
{
    char name[100];

    mg_get_http_var(&message->body, "name", name, sizeof(name));
    set_default_header(connection);
    set_module_data(connection, name);
    mg_send_http_chunk(connection, "", 0);
}

void request_handler(struct mg_connection *connection, int event, void *data)
{
    struct http_message *message = (struct http_message *)data;

    switch (event) {
    case MG_EV_HTTP_REQUEST:
        if (mg_vcmp(&message->uri, "/module") == 0)
            handle_module(connection, message);
        else
            mg_serve_http(connection, message, opts);
        break;
    default:
        break;
    }
}

int main()
{
    struct mg_mgr mgr;
    struct mg_connection *connection;

    mg_mgr_init(&mgr, NULL);
    connection = mg_bind(&mgr, port, request_handler);
    mg_set_protocol_http_websocket(connection);
    opts.document_root = ".";
    printf("Starting sermonit on port %s.\n", port);

    for (;; )
        mg_mgr_poll(&mgr, 1000);

    mg_mgr_free(&mgr);
    return 0;
}
