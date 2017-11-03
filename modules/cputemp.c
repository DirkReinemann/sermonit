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
} Temp;

typedef struct {
    Temp *temps;
    int   length;
} Stat;

const char *DIR_THERMAL = "/sys/class/thermal";
const char *FILE_TEMP = "temp";
const char *REGEX_THERMAL = "^thermal_zone";

void read_stats(Stat *stat)
{
    DIR *dir = opendir(DIR_THERMAL);

    stat->temps = malloc(sizeof(Temp));

    if (dir != NULL) {
        struct dirent *entry;
        regex_t regex;
        regcomp(&regex, REGEX_THERMAL, 0);
        int i = 0;
        while ((entry = readdir(dir)) != NULL) {
            if (entry->d_type == DT_LNK && !regexec(&regex, entry->d_name, 0, NULL, 0)) {
                char filepath[BUFSIZ];
                snprintf(filepath, BUFSIZ - 1, "%s/%s/%s", DIR_THERMAL, entry->d_name, FILE_TEMP);
                if (access(filepath, F_OK) != -1) {
                    FILE *file = fopen(filepath, "r");
                    if (file != NULL) {
                        char *line;
                        size_t size;
                        getline(&line, &size, file);
                        int temp = atol(line) / 1000;
                        free(line);
                        fclose(file);

                        if (i > 0)
                            stat->temps = realloc(stat->temps, (i + 1) * sizeof(Stat));

                        (stat->temps + i)->temp = temp;
                        i++;
                    }
                }
            }
        }
        closedir(dir);
        stat->length = i;
    }
}

int main()
{
    Stat stat;

    read_stats(&stat);
    char result[1024];
    result[0] = '\0';
    int len = 0;
    for (int i = 0; i < stat.length; i++) {
        char temp[64];
        size_t l = snprintf(temp, 64, "{\"processor\":\"processor %d\",\"temperature\":\"%d\"},", i + 1, (stat.temps + i)->temp);
        strncpy(result + len, temp, l + 1);
        len += l;
    }
    if (strlen(result) > 0) {
        result[len - 1] = '\0';
        printf("[%s]\n", result);
    } else {
        printf("[]\n");
    }
    free(stat.temps);
    return 0;
}
