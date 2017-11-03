// dependencies: /proc/meminfo

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <regex.h>
#include <math.h>

typedef struct {
    long   total;
    long   available;
    double percent;
} Mem;

const char *FILE_MEMINFO = "/proc/meminfo";
const char *REGEX_MEM_TOTAL = "^MemTotal";
const char *REGEX_MEM_AVAILABLE = "^MemFree";
const char *REGEX_SWAP_TOTAL = "^SwapTotal";
const char *REGEX_SWAP_AVAILABLE = "^SwapFree";

void read_stat(char *line, const char *sregex, long *value)
{
    regex_t regex;

    regcomp(&regex, sregex, 0);
    if (!regexec(&regex, line, 0, NULL, 0)) {
        char *token = strtok(line, " ");
        int i = 0;
        while (token) {
            if (i == 1) {
                long result = strtol(token, NULL, 10);
                if (result > 0)
                    *(value) = result;
            }
            token = strtok(NULL, " ");
            i++;
        }
    }
}

void calc_percent(Mem *mem)
{
    mem->percent = (double)100.0 - (100.0 * mem->available / mem->total);
}

void read_mem(Mem *mem, Mem *swap)
{
    FILE *file = fopen(FILE_MEMINFO, "r");

    if (file != NULL) {
        size_t len;
        ssize_t read;
        char *line = NULL;
        while ((read = getline(&line, &len, file)) != -1) {
            read_stat(line, REGEX_MEM_TOTAL, &(mem->total));
            read_stat(line, REGEX_MEM_AVAILABLE, &(mem->available));
            read_stat(line, REGEX_SWAP_TOTAL, &(swap->total));
            read_stat(line, REGEX_SWAP_AVAILABLE, &(swap->available));
            calc_percent(mem);
            calc_percent(swap);
        }
        free(line);
        fclose(file);
    }
}

int main()
{
    Mem mem;
    Mem swap;

    mem.total = 0;
    mem.available = 0;
    swap.total = 0;
    swap.available = 0;

    read_mem(&mem, &swap);

    printf("[{\"type\":\"memory\",\"percent\":\"%.0f\"},{\"type\":\"swap\",\"percent\":\"%.0f\"}]\n", mem.percent, swap.percent);

    return 0;
}
