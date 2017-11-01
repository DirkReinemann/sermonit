#include <stdio.h>
#include <stdlib.h>
#include <regex.h>
#include <string.h>
#include <unistd.h>
#include <math.h>

const char *FILENAME = "/proc/stat";

typedef struct {
    int idle;
    int total;
} Cpu;

typedef struct {
    Cpu *cpus;
    int  length;
} Stat;

void read_stats(Stat *stat)
{
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    regex_t regex;

    regcomp(&regex, "^cpu[0-9]", 0);
    FILE *file = fopen(FILENAME, "r");
    stat->cpus = malloc(sizeof(Stat));

    if (file) {
        int i = 0;
        while ((read = getline(&line, &len, file)) != -1) {
            if (!regexec(&regex, line, 0, NULL, 0)) {
                int total = 0;
                int idle = 0;
                int c = 0;
                char *token = strtok(line, " ");

                if (i > 0)
                    stat->cpus = realloc(stat->cpus, (i + 1) * sizeof(Stat));

                while (token) {
                    int val = strtol(token, NULL, 10);
                    if (c == 4)
                        idle = val;
                    total += val;
                    token = strtok(NULL, " ");
                    c++;
                }
                (stat->cpus + i)->idle = idle;
                (stat->cpus + i)->total = total;
                i++;
            }
        }
        fclose(file);
        stat->length = i;
    } else {
        printf("Cannot open file '%s\n.'", FILENAME);
    }
}

int main()
{
    char result[1024];
    Stat stat1;
    Stat stat2;

    read_stats(&stat1);
    sleep(1);
    read_stats(&stat2);
    int len = 0;
    for (int i = 0; i < stat1.length; i++) {
        double idle = (double)(*(stat2.cpus + i)).idle - (*(stat1.cpus + i)).idle;
        double total = (double)(*(stat2.cpus + i)).total - (*(stat1.cpus + i)).total;
        double percent = ceil(((double)1000 * (total - idle) / total + (double)5) / (double)10);

        char temp[64];
        size_t l = snprintf(temp, 64, "{\"core\":\"core %d\",\"percent\":\"%d\"},", i + 1, (int)percent);
        strncpy(result + len, temp, l + 1);
        len += l;
    }
    result[len - 1] = '\0';
    printf("[%s]\n", result);
    free(stat1.cpus);
    free(stat2.cpus);
    return 0;
}
