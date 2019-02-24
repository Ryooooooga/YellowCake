#ifndef INCLUDE_Akouta_h
#define INCLUDE_Akouta_h

#include <stddef.h>
#include <stdint.h>

typedef struct Akouta_Function Akouta_Function;

Akouta_Function* Akouta_Function_new(const uint8_t* binary, size_t size);
void Akouta_Function_delete(Akouta_Function* f);

int32_t Akouta_Function_execute_i32(const Akouta_Function* f);

#endif // INCLUDE_Akouta_h
