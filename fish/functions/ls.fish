function ls --wraps='eza -al --color=always --group-directories-first --icons' --wraps='eza --icons --group-directories-first' --description 'alias ls eza --icons --group-directories-first'
    eza --icons --group-directories-first $argv
end
