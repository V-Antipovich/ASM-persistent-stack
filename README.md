# Assembly x86-64 persistent stack:)
Using intell syntax

(I'm a little bit crazy)
## Build and run

```
gcc -g pers_stack.S simpleio_x86_64.S -o pers_stack

./pers_stack
```

## How to use
Works properly for <=1000 commands from standart input:
0 i x - push(i, x);
1 i - pop(i);

numbers should fit into 32-int
and please do not pop from non-existing states of stack
