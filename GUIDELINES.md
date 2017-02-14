# Coding guidelines

## shell

Stella is intended to work at least with bash. But we will try to stick as possible to POSIX shell.


## guide

| avoid  | use | note |
| ------ | --- | ------- |
| ==  | =  ||
| [[ ]] | [ ] | [[ is not POSIX but largely supported across shell. Often it is recommended to use [[  over [. But for now we stick to POSIX |
