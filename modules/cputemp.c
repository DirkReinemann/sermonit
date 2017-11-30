// dependencies: /sys/class/thermal/thermal_zone[0-9]

#include <stdlib.h>
#include <stdio.h>
#include <dirent.h>
#include <sys/types.h>
#include <string.h>
#include <regex.h>
#include <unistd.h>

typedef struct {
    int temp;
} temp;

typedef struct {
    int   size;
    temp *ts;
} stat;

const char *DIR_THERMAL = "/sys/class/thermal";
const char *FILE_TEMP = "temp";
const char *REGEX_THERMAL = "^thermal_zone";

void read_stats(stat *s)
{
    DIR *dir = opendir(DIR_THERMAL);

    if (dir != NULL) {
        struct dirent *entry;
        regex_t regex;
        regcomp(&regex, REGEX_THERMAL, 0);
        while ((entry = readdir(dir)) != NULL) {
            if (entry->d_type == DT_LNK && !regexec(&regex, entry->d_name, 0, NULL, 0)) {
                size_t sfilepath = strlen(DIR_THERMAL) + strlen(entry->d_name) + strlen(FILE_TEMP) + 4;
                char filepath[sfilepath];
                snprintf(filepath, BUFSIZ - 1, "%s/%s/%s", DIR_THERMAL, entry->d_name, FILE_TEMP);
                if (access(filepath, F_OK) != -1) {
                    FILE *file = fopen(filepath, "r");
                    if (file != NULL) {
                        char *line = NULL;
                        size_t size = 0;
                        getline(&line, &size, file);
                        if (line != NULL) {
                            s->ts = (temp *)realloc(s->ts, (s->size + 1) * sizeof(temp));
                            temp *t = s->ts + s->size;
                            int temp = atol(line);
                            if (temp > 1000)
                                temp /= 1000;
                            t->temp = temp;
                            s->size++;
                            free(line);
                        }
                        fclose(file);
                    }
                }
            }
        }
        closedir(dir);
    }
}

int main()
{
    stat s;

    s.size = 0;
    s.ts = (temp *)malloc(0 * sizeof(temp));

    read_stats(&s);
    char *result = (char *)malloc(1 * sizeof(char));
    result[0] = '\0';

    const char *format = "{\"processor\":\"processor %d\",\"temperature\":\"%d\"},";
    size_t sformat = strlen(format) + 2;
    size_t pos = 0;
    for (int i = 0; i < s.size; i++) {
        temp *t = s.ts + i;

        char data[sformat];
        snprintf(data, sformat, format, i + 1, t->temp);
        size_t sdata = strlen(data);

        result = (char *)realloc(result, (pos + sdata) * sizeof(char));
        strncpy(result + pos, data, sdata);

        pos += sdata;
    }
    result[pos - 1] = '\0';

    if (strlen(result) > 0)
        printf("[%s]\n", result);
    else
        printf("[]\n");

    free(result);
    free(s.ts);
    return 0;
}
