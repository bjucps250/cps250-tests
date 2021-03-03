// File: ex3_args_test.c

#include <stdio.h>
#include <string.h>
#include <bsd/string.h>
#include <stdlib.h>
#include <limits.h>
#include <errno.h>

static const int FILENAME_BUFSIZE = 10;
static const int ERRMSG_BUFSIZE = 50;

int parseArgs(int argc, char **argv, char infile[], long *size, int *help, char errmsg[]);

static int numTests = 0;
static int numPassedTests = 0;

#define CHECK_INT_EQ(expect, actual) { numTests++; if (expect != actual) { printf("** Line %d: Expected %ld, got %ld\n", __LINE__, (long)expect, (long)actual); } else { numPassedTests++; } }
#define CHECK_STR_EQ(expect, actual) { numTests++; if (strcmp(expect, actual) != 0) { printf("** Line %d: Expected '%s', got '%s'\n", __LINE__, expect, actual); } else { numPassedTests++; } }

void official_unit_test()
{
    
    long size;
    int help;
    char errmsg[ERRMSG_BUFSIZE];
    int result;
    char infile[FILENAME_BUFSIZE];

    errmsg[0] = '\0';
    infile[0] = '\0';

    puts("Test 1: Valid size and filename (args -s 300 bf)");

    errmsg[0] = '\0';
    infile[0] = '\0';

    char *args1[] = { "args", "-s", "300", "bf", NULL };
    result = parseArgs(4, args1, infile, &size, &help, errmsg);
    CHECK_INT_EQ(1, result);
    CHECK_STR_EQ("bf", infile);
    CHECK_INT_EQ(300, size);
    CHECK_INT_EQ(0, help);
    
    puts("Test 2: Valid filename with path (args -h -pout afile)");

    char *args2[] = { "args", "-h", "-pout", "afile", NULL };
    result = parseArgs(4, args2, infile, &size, &help, errmsg);
    CHECK_INT_EQ(1, result);
    CHECK_STR_EQ("out/afile", infile);
    CHECK_INT_EQ(0, size);
    CHECK_INT_EQ(1, help);

    puts("Test 3: Error: no filename supplied (args -h)");

    char *args3[] = { "args", "-h", NULL };
    result = parseArgs(2, args3, infile, &size, &help, errmsg);
    CHECK_INT_EQ(0, result);
    CHECK_STR_EQ("no filename supplied", errmsg);

    puts("Test 4: Error: filename too long (args -pdefghi abc)");

    char *args4[] = {  "args", "-pdefghi", "abc", NULL };
    result = parseArgs(3, args4, infile, &size, &help, errmsg);
    CHECK_INT_EQ(0, result);
    CHECK_STR_EQ("filename too long", errmsg);
    
    puts("Test 5: Error: size is not a valid number (args -s 99a file)");

    char *args5[] = {  "args", "-s", "99a", "file", NULL };
    result = parseArgs(4, args5, infile, &size, &help, errmsg);
    CHECK_INT_EQ(0, result);
    CHECK_STR_EQ("size is not a valid number", errmsg);
    
    puts("Test 6: Error: invalid argument -q (args -q file)");

    char *args6[] = {  "args", "-q", "file", NULL };
    result = parseArgs(3, args6, infile, &size, &help, errmsg);
    CHECK_INT_EQ(0, result);
    CHECK_STR_EQ("invalid argument -q", errmsg);

    puts("Test 7: Error: invalid argument - (args - file)");

    char *args7[] = {  "args", "-", "file", NULL };
    result = parseArgs(3, args7, infile, &size, &help, errmsg);
    CHECK_INT_EQ(0, result);
    CHECK_STR_EQ("invalid argument -", errmsg);

    puts("Test 8: Error: missing path (args -p file)");

    char *args8[] = {  "args", "-p", "file", NULL };
    result = parseArgs(3, args8, infile, &size, &help, errmsg);
    CHECK_INT_EQ(0, result);
    CHECK_STR_EQ("missing path", errmsg);

    printf("Passed %d of %d checks.\n", numPassedTests, numTests);
}


int main(int argc, char **argv)
{
    official_unit_test();
}
