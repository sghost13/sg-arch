#!/usr/bin/env zsh

# $HOME/shell/zsh/setopt.zsh

# Use this file to to set all setopt options. May be overridden by any plugins/prompts.

## ----------------- shell-options

# History stuff
setopt HIST_EXPIRE_DUPS_FIRST               #
setopt HIST_IGNORE_DUPS                     # Don't enter dups into hist
setopt HIST_IGNORE_ALL_DUPS                 # If a new command is a duplicate, remove the older one
setopt HIST_FIND_NO_DUPS                    # Don't display dups of a line when searching in line e
setopt HIST_SAVE_NO_DUPS                    # Delete older dups from hist
setopt HIST_REDUCE_BLANKS                   # Remove superfluous blanks when adding to hist
setopt HIST_VERIFY                          # Dont execute, expand and reload into editing buffer instead
setopt APPEND_HISTORY                       # Immediately append history instead of overwriting
setopt EXTENDED_HISTORY                     # Save commands timestamp and duration to hist file
setopt INC_APPEND_HISTORY                   # Icrementally add to hist

# globs
setopt NULL_GLOB                            # Remove pattern rather than error from no match from glob
setopt EXTENDED_GLOB                        # Extended globbing. Allows using regular expressions with *
setopt NO_CASE_GLOB                         # Case insensitive globbing
setopt BAD_PATTERN                          # Print error on badly formed glob
setopt NUMERIC_GLOB_SORT                    # Sort filenames numerically in globs when it makes sense

# dir stuff
setopt AUTOCD                               # If only directory path is entered, cd there.
setopt AUTO_PUSHD                           # Make cd push old dir onto dir stack

# Kill all the beeps
setopt NO_BEEP NO_HIST_BEEP                 # No beeps here
unsetopt BEEP LIST_BEEP HIST_BEEP           # Get outta here, ya stinkin beeps

setopt ALIASES                              # Expand Aliases
setopt COMPLETE_ALIASES                     # alias becomes distinct command for completion purposes
setopt CORRECT                              # Auto correct mistakes

# SH_WORD_SPLIT causes syntax-highlighting to break
#setopt SH_WORD_SPLIT                        # Cause field splitting on unquoted parameter expansions.

#setopt POSIX_CD

