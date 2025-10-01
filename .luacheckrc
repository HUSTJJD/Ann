std                     = "lua53"
globals                 = {
    'Ann',
    'UnLua',
    'UE',
    'rapidjson',
}

include_files           = {
    'Content/**/*.lua',
}

exclude_files           = {
    'Content/UnLua/**/*.lua',
}

ignore                  = {
    '212/self', --Unused Argument "self"
    '212/...',  --Unused Argument "..."
    '542',      --empty if branch
}

max_line_length         = 500
max_code_line_length    = 500
max_string_line_length  = 500
max_comment_line_length = 500
