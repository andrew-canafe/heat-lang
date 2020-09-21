# The Heat Programming Language
Prototype for a simplistic programming language that I am currently designing. Inspiration was taken from many traditional and modern (OOP) languages, but mostly from C, Go, and Pascal.

## Reserved Keywords
asm, break, case, class, elif, else, f32, f64, for, func, i128, i16, i32, i64, i8, if, import, match, next, ptr, return, str, u128, u16, u32, u64, u8, var, while

## Language Philosophy
### The simplest solution is often times the best solution
Heat completely removes do-while loops and `goto` statements, as they are confusing and seldom ever used. Heat replaces `switch` statements with `match` statements, which are similar to `switch` statements except that they do not use `break` to escape the body of the container and do not require inner `case` statements. Heat completely removes the `&&` and `||` logical operators, as any sequence of logical operations can always be replicated using bitwise operations. Heat replaces `else` and `if` keyword pairs with a single `elif` keyword, as it reduces the amount of characters the programmer needs to type. On a similar note, Heat uses the `next` keyword instead of the `continue` keyword found in most programming languages. Heat uses a less complex for-loop syntax with a style similar to Lua. Heat does not use a `char` keyword, but instead uses a `str` keyword which is equivalent to a `char` pointer, for readability purposes.

### Coding style shall be stricly enforced by the language
Heat replaces the usage of semicolons with mandatory newlines, as missing semicolons only result in wasted time during the debugging process. Heat requires the use of a `var` block container when initializing variables. This separates variable initialization from the actual logic of the program, as the programmer will be inclined to create new `var` blocks sparingly.

### Give full power and responsibility to the programmer
Heat allows for unsafe type casting and unsafe memory access, similar to C. Heat supports pointer arithmetic, but offsets are always calculated using one-byte sizes and never using the sizes of the pointed-to variables, as this gives the programmer more control over the individual bytes of array structures. Heat supports multi-level `break` statements with depths that can be specified in the `break` statements themselves, as this gives more power to the language as a whole. Heat does not support garbage collection, for obvious performance reasons.

### Use different symbols for different things
Heat removes ambiguities between multiplication and indirection operators by using the `$` symbol instead of the `*` symbol for the  indirection operator. Heat removes ambiguities between bitwise-and and address-of operators by using the `@` symbol instead of the `&` symbol for the address-of operator. Heat uses the `:=` symbol for assignment and the `=` symbol for equality comparison to make assignment and equality comparison easily distinguishable.

### All actions should be explicity defined
Heat makes it mandatory for the initialization of variables to be explicit and does not support zero-by-default initialization. Heat requires a type to be associated with each variable and does not support `auto` specifiers, as they are confusing in the process of reading source code.

### Class inheritance is the root of all evil
Heat does not support class inheritance, as it is difficult to maintain and results in monolithic source code. However, Heat still uses classes for the purpose of class instantiation and source code modularity.
