# obtain_options

Created by [shlok](https://github.com/shlok) for use in personal projects. Use at your own risk.

``obtain_options`` is a Bash function for obtaining command-line options.

## Requirements

Bash 4 or later.

Installation on macOS: (1) `brew install bash`. (2) In Terminal → Preferences → General, change shell path to `/usr/local/bin/bash`. (3) In Terminal → Preferences → Profiles → Shell, add `-bash` to the table view. (4) Confirm that `/usr/local/bin` appears before `/bin` in `$PATH`.

## Usage

Example:

```bash
#!/usr/bin/env bash

value_options=("--file" "-c" "--format")
one_letter_count_options=("a" "v")
multi_letter_count_options=("archive" "verbose")

declare -A option_values
declare -A option_counts
non_option_arguments=()

. ./obtain_options.bash
obtain_options "$@"
if [[ $? > 0 ]]; then
    echo "Usage: ..."
    exit 1
fi
```

declare -p option_values
declare -p option_counts
declare -p non_option_arguments

Running this script with the arguments

    --file foo.txt -c=5 --format="a b c" -avv --archive --verbose -- other args

gives us this result:

    declare -A option_values=([-c]="5" [--file]="foo.txt" [--format]="a b c" )
    declare -A option_counts=([archive]="1" [verbose]="1" [a]="1" [v]="2" )
    declare -a non_option_arguments=([0]="other" [1]="args")
