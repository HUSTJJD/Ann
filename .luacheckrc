std                     = "lua53"
globals                 = {
    'Ann',
    'UnLua',
    'UE',
    'rapidjson',
}

include_files           = {
    'Content/Script/**/*.lua'
}

exclude_files           = {
}

ignore = {
    '212/self', --Unused Argument "self"
    '542', --empty if branch
}

max_line_length         = 500
max_code_line_length    = 500
max_string_line_length  = 500
max_comment_line_length = 500
