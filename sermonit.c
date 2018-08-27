#include <stdlib.h>
#include <stdio.h>

#include "mongoose.h"

static const char *port = "127.0.0.1:8000";
static const char *modulesdir = "modules";
static const int threads = 5;
static sig_atomic_t received_signal = 0;
static unsigned long next_id = 0;
static sock_t sock[2];

struct mg_serve_http_opts opts;

struct work_request
{
    unsigned long conn_id;
    char name[100];
};

struct work_result
{
    unsigned long conn_id;
    char *data;
};

static void signal_handler(int sig_num) 
{
    signal(sig_num, signal_handler);
    received_signal = sig_num;
}

static void set_default_header(struct mg_connection *connection)
{
    mg_printf(connection, "%s", "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nTransfer-Encoding: chunked\r\n\r\n");
}

static void set_error_response(struct mg_connection *connection)
{
    mg_printf_http_chunk(connection, "\r\n");
}

static void on_work_complete(struct mg_connection *connection, int event, void *data) {
    (void) event;
    struct mg_connection *c;

    for (c = mg_next(connection->mgr, NULL); c != NULL; c = mg_next(connection->mgr, c)) {
        if (c->user_data != NULL) {
            struct work_result *result = (struct work_result *)data;
            if ((unsigned long)c->user_data == result->conn_id) {
                if (strlen(result->data) == 0) {
                    set_error_response(connection);
                }
                else {
                    set_default_header(connection);
                }
                printf("%s\n", result->data);
                mg_printf_http_chunk(connection, result->data);
                mg_send_http_chunk(connection, "", 0);
            }
        }
    }
}

void *worker_thread_proc(void *param) {
    struct mg_mgr *mgr = (struct mg_mgr *) param;
    struct work_request request = {0};

    while (received_signal == 0) {
        if (read(sock[1], &request, sizeof(request)) < 0)
            perror("Reading worker sock");

        FILE *pipe;
        char *file;
        char *line = NULL;
        size_t n = 0;

        struct work_result result;
        result.conn_id = request.conn_id;
        result.data = calloc(sizeof(char), 1);

        n = strlen(modulesdir) + strlen(request.name) + 4;
        file = calloc(n, sizeof(char));
        snprintf(file, n, "./%s/%s", modulesdir, request.name);
        pipe = popen(file, "r");

        if (pipe != NULL) {
            ssize_t read = getline(&line, &n, pipe);
            if (read > 0) {
                n = strlen(line) + 1;
                result.data = realloc(result.data, sizeof(char) * n);
                strncpy(result.data, line, read);
                result.data[n - 1] = '\0';
            }
            free(line);
            pclose(pipe);
        }
        free(file);

        mg_broadcast(mgr, on_work_complete, (void *)&result, sizeof(result));
    }
    return NULL;
}

static void request_handler(struct mg_connection *connection, int event, void *data)
{
    struct http_message *message = (struct http_message *)data;

    switch (event) {
        case MG_EV_ACCEPT:
            connection->user_data = (void *)++next_id;
            break;
        case MG_EV_HTTP_REQUEST:
            if (mg_vcmp(&message->uri, "/module") == 0) {
                struct work_request request;

                request.conn_id = (unsigned long)connection->user_data;
                mg_get_http_var(&message->body, "name", request.name, sizeof(request.name));

                if (write(sock[0], &request, sizeof(request)) < 0)
                    perror("Writing worker sock!");
            } else {
                mg_serve_http(connection, message, opts);
            }
            break;
        case MG_EV_CLOSE:
            if (connection->user_data)
                connection->user_data = NULL;
            break;
        default:
            break;
    }
}

int main()
{
    struct mg_mgr mgr;
    struct mg_connection *connection;

    if (mg_socketpair(sock, SOCK_STREAM) == 0) {
        printf("Opening socket pair\n");
        return 1;
    }

    signal(SIGTERM, signal_handler);
    signal(SIGINT, signal_handler);

    mg_mgr_init(&mgr, NULL);
    connection = mg_bind(&mgr, port, request_handler);
    if (connection == NULL) {
        printf("Failed to create listener\n");
        return 1;
    }

    mg_set_protocol_http_websocket(connection);
    opts.document_root = ".";

    for (int i = 0; i < threads; i++) {
        mg_start_thread(worker_thread_proc, &mgr);
    }

    printf("Starting sermonit on port %s.\n", port);

    for (;;)
        mg_mgr_poll(&mgr, 1000);

    mg_mgr_free(&mgr);
    closesocket(sock[0]);
    closesocket(sock[1]);
    return 0;
}
