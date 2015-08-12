# from Example 26-14. Emulating a push-down stack 
# http://www.linuxtopia.org/online_books/advanced_bash_scripting_guide/arrays.html

# stack.sh: push-down stack simulation

#  Similar to the CPU stack, a push-down stack stores data items
#+ sequentially, but releases them in reverse order, last-in first-out.


#BP=100            #  Base Pointer of stack array.
                  #  Begin at element 100.

_STELLA_STACK_SP=0
#SP=$BP            #  Stack Pointer.
                  #  Initialize it to "base" (bottom) of stack.

#Data=             #  Contents of stack location.  
                  #  Must use global variable,
                  #+ because of limitation on function return range.

declare -a _STELLA_STACK_


__stack_push()            # Push item on stack.
{
if [ -z "$1" ]    # Nothing to push?
then
  return
fi

_STELLA_STACK_SP=$(( _STELLA_STACK_SP + 1 ))
_STELLA_STACK_[$_STELLA_STACK_SP]="$1"

return
}

__stack_pop()                    # Pop item off stack.
{
local Data=                    # Empty out data item.

if [ "$_STELLA_STACK_SP" -eq "0" ]   # Stack empty?
then
  echo
else                      #  This also keeps SP from getting past 100,
                         #+ i.e., prevents a runaway stack.

Data="${_STELLA_STACK_[$_STELLA_STACK_SP]}"
_STELLA_STACK_SP=$(( _STELLA_STACK_SP - 1 ))
echo $Data
fi
}



