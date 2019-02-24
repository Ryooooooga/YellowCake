#include "Akouta.h"

#include <assert.h>
#include <memory.h>
#include <stdlib.h>
#include <sys/mman.h>

struct Akouta_Function {
    uint8_t* binary;
    size_t size;
};

Akouta_Function* Akouta_Function_new(const uint8_t* binary, size_t size) {
    Akouta_Function* f = malloc(sizeof(*f));

    if (f == NULL) {
        return NULL;
    }

    f->binary = mmap(NULL, size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

    if (f->binary == MAP_FAILED) {
        free(f);
        return NULL;
    }

    f->size = size;
    memcpy(f->binary, binary, f->size);

    return f;
}

void Akouta_Function_delete(Akouta_Function* f) {
    if (f) {
        munmap(f->binary, f->size);
        free(f);
    }
}

int32_t Akouta_Function_execute_i32(const Akouta_Function* f) {
    assert(f);
    return ((int (*)(void))f->binary)();
}
